//
//  ShareViewController.swift
//  LynkShare
//
//  Created by Zabir Raihan on 04/10/2025.
//

import UIKit
import UniformTypeIdentifiers

/// Minimal, UI-less Share Extension that:
/// 1. Extracts the first URL or text payload (or combines multiple items if present)
/// 2. Stores it in the shared App Group UserDefaults
/// 3. Wakes the main app via custom URL scheme (lynkchat://share)
/// 4. Immediately completes the request (no custom UI)
class ShareViewController: UIViewController {
    private enum Const {
        static let groupID = "group.com.temporary.lynkchat"
        static let contentKey = "sharedContent"
        static let imagePathsKey = "sharedImagePaths"
        static let dateKey = "sharedContentDate"
        static let schemeURL = "lynkchat://share"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        processIncomingItems()
    }

    private func processIncomingItems() {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem],
              !inputItems.isEmpty else {
            finish()
            return
        }

        let providers = inputItems.compactMap { $0.attachments }.flatMap { $0 }
        guard !providers.isEmpty else {
            finish()
            return
        }

        // Collect text/URL strings and image file paths from each provider
        var collected: [String] = []
        var imagePaths: [String] = []
        let group = DispatchGroup()
        let lock = NSLock()

        for provider in providers {
            // Prioritize image over URL/text for each provider
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, error in
                    defer { group.leave() }
                    guard let imageData = Self.imageData(from: item) else { return }
                    if let path = Self.saveImageToSharedContainer(imageData) {
                        lock.lock(); imagePaths.append(path); lock.unlock()
                    }
                }
                continue
            }
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, error in
                    if let url = (item as? URL) ?? (item as? NSURL as URL?) {
                        lock.lock(); collected.append(url.absoluteString); lock.unlock()
                    } else if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        lock.lock(); collected.append(url.absoluteString); lock.unlock()
                    }
                    group.leave()
                }
                continue
            }
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, error in
                    if let text = item as? String { lock.lock(); collected.append(text); lock.unlock() }
                    group.leave()
                }
                continue
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            let hasText = !collected.isEmpty
            let hasImages = !imagePaths.isEmpty
            guard hasText || hasImages else {
                self.finish()
                return
            }
            if hasText {
                let payload = collected.count > 1 ? collected.joined(separator: "\n") : collected.first!
                self.storeText(payload)
            }
            if hasImages {
                self.storeImagePaths(imagePaths)
            }
            self.openHostAppAndFinish()
        }
    }

    private func storeText(_ string: String) {
        guard let ud = UserDefaults(suiteName: Const.groupID) else { return }
        ud.set(string, forKey: Const.contentKey)
        ud.set(Date(), forKey: Const.dateKey)
        ud.synchronize()
    }

    private func storeImagePaths(_ paths: [String]) {
        guard let ud = UserDefaults(suiteName: Const.groupID) else { return }
        ud.set(paths, forKey: Const.imagePathsKey)
        ud.set(Date(), forKey: Const.dateKey)
        ud.synchronize()
    }

    /// Convert the loaded item into JPEG data regardless of its original form.
    private static func imageData(from item: NSSecureCoding?) -> Data? {
        if let url = item as? URL, let data = try? Data(contentsOf: url) {
            return UIImage(data: data)?.jpegData(compressionQuality: 0.85)
        }
        if let image = item as? UIImage {
            return image.jpegData(compressionQuality: 0.85)
        }
        if let data = item as? Data {
            return UIImage(data: data)?.jpegData(compressionQuality: 0.85)
        }
        return nil
    }

    /// Save image data into the shared App Group container and return the file path.
    private static func saveImageToSharedContainer(_ data: Data) -> String? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Const.groupID) else { return nil }
        let imagesDir = containerURL.appendingPathComponent("SharedImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = imagesDir.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            return nil
        }
    }

    private func openHostAppAndFinish() {
        guard let url = URL(string: Const.schemeURL) else { finish(); return }
        var responder: UIResponder? = self
        while let current = responder {
            if let app = current as? UIApplication {
                if #available(iOS 18.0, *) {
                    app.open(url, options: [:]) { _ in }
                } else {
                    _ = app.perform(#selector(UIApplication.openURL(_:)), with: url)
                }
                // Complete quickly – no UI to show.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in self?.finish() }
                return
            }
            responder = current.next
        }
        finish()
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
