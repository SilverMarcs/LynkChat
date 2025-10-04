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

        // Collect first URL or text from each provider (usually only one in real-world share sheet usage)
        var collected: [String] = []
        let group = DispatchGroup()
        let lock = NSLock()

        for provider in providers {
            // Prioritize URL over text for each provider
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
            guard let first = collected.first else {
                self.finish()
                return
            }
            // If multiple, join with newlines so main app can parse later.
            let payload = collected.count > 1 ? collected.joined(separator: "\n") : first
            self.store(payload)
            self.openHostAppAndFinish()
        }
    }

    private func store(_ string: String) {
        guard let ud = UserDefaults(suiteName: Const.groupID) else {
            return
        }
        ud.set(string, forKey: Const.contentKey)
        ud.set(Date(), forKey: Const.dateKey)
        ud.synchronize()
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
