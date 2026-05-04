//
//  InputFileHandler.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

extension InputManager {
    // Define constants
    enum Constants {
        static let maxFileSizeBytes: Int = 10 * 1024 * 1024 // 10MB in bytes
        static let maxTotalFiles: Int = 15
        static let maxAudioFiles: Int = 1
        static let pasteTextToFileThreshold: Int = 6500
    }
    
    func processData(_ data: Data, fileType: UTType? = nil, fileName: String? = nil, url: URL? = nil) async throws {
        let fileURL = url ?? URL(fileURLWithPath: fileName ?? "Unknown")
        let fileType = fileType ?? (try? fileURL.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier).flatMap { UTType($0) } ?? .data
        let fileName = fileName ?? fileURL.deletingPathExtension().lastPathComponent + "." + (fileType.preferredFilenameExtension ?? "")

        var processedData = data
        var processedFileType = fileType
        var processedFileName = fileName
        
        // Process images for compression if needed
        if fileType.conforms(to: .image) {
            let result = try ImageProcessor.processImageData(data, fileType: fileType, fileName: fileName)
            processedData = result.0
            processedFileType = result.1
            processedFileName = result.2
        }
        
        // Check file size after processing
        guard processedData.count <= Constants.maxFileSizeBytes else {
            throw InputError.fileTooLarge(size: processedData.count, maxSize: Constants.maxFileSizeBytes)
        }

        let typedData = TypedData(
            data: processedData,
            fileType: processedFileType,
            fileName: processedFileName
        )
        
        // Check total file limit
        if dataFiles.count >= Constants.maxTotalFiles {
            throw InputError.tooManyFiles(current: dataFiles.count, max: Constants.maxTotalFiles)
        }
        
        // Check audio file limit
        if processedFileType.conforms(to: .audio) {
            let existingAudioFiles = dataFiles.filter { $0.fileType.conforms(to: .audio) }
            if existingAudioFiles.count >= Constants.maxAudioFiles {
                throw InputError.tooManyAudioFiles(max: Constants.maxAudioFiles)
            }
        }
        
        // Remove existing file with the same name, if any
        if let existingIndex = self.dataFiles.firstIndex(where: { $0.fileName == processedFileName }) {
            self.dataFiles.remove(at: existingIndex)
        }
        
        withAnimation {
            self.dataFiles.insert(typedData, at: 0)
        }
    }
    
    func processFile(at url: URL) async throws {
        // Check file size before loading data
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = fileAttributes[.size] as? Int ?? 0
        
        guard fileSize <= Constants.maxFileSizeBytes else {
            throw InputError.fileTooLarge(size: fileSize, maxSize: Constants.maxFileSizeBytes)
        }
        
        let data = try Data(contentsOf: url)
        try await processData(data, url: url)
    }
}

// MARK: - Dropping
extension InputManager {
    func handleDrop(_ providers: [NSItemProvider]) throws -> Bool {
        guard !providers.isEmpty else { return false }

        for provider in providers {
            // Prefer a concrete image type if the provider advertises one.
            // Screenshot drag thumbnails list a private identifier first, which
            // would otherwise be loaded as a .dat blob and skip ImageProcessor.
            if let imageType = preferredImageType(for: provider) {
                provider.loadDataRepresentation(forTypeIdentifier: imageType.identifier) { [weak self] data, _ in
                    guard let self, let data else { return }
                    let ext = imageType.preferredFilenameExtension ?? "png"
                    let fileName = "Image_\(UUID().uuidString).\(ext)"
                    Task {
                        try? await self.processData(data, fileType: imageType, fileName: fileName)
                    }
                }
                continue
            }

            // Fall back: generic file representation for non-image files
            provider.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { url, _ in
                guard let url = url else { return }

                guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                      let fileSize = fileAttributes[.size] as? Int,
                      fileSize <= Constants.maxFileSizeBytes else {
                    print("File size exceeds maximum limit")
                    return
                }

                let fileName = url.lastPathComponent
                let typeIdentifier = provider.registeredTypeIdentifiers.first

                provider.loadDataRepresentation(forTypeIdentifier: UTType.item.identifier) { data, error in
                    guard let data = data else {
                        print("Failed to load data representation")
                        return
                    }

                    Task { [weak self] in
                        guard let self else { return }
                        let fileType = typeIdentifier.flatMap { UTType($0) } ?? .data
                        try await self.processData(data, fileType: fileType, fileName: fileName)
                    }
                }
            }
        }

        return true
    }

    private func preferredImageType(for provider: NSItemProvider) -> UTType? {
        // Specific types first, then a generic .image fallback so the
        // most accurate extension wins when multiple are advertised.
        let candidates: [UTType] = [.png, .jpeg, .heic, .heif, .gif, .tiff, .webP, .bmp, .image]
        return candidates.first { type in
            provider.hasItemConformingToTypeIdentifier(type.identifier)
        }
    }
    
    func loadTransferredPhotos(from selectedPhotos: [PhotosPickerItem]) async throws {
        for photo in selectedPhotos {
            guard let data = try? await photo.loadTransferable(type: Data.self) else {
                throw RuntimeError("Failed to load photo data")
            }

            let detectedType = photo.supportedContentTypes.first { $0.conforms(to: .image) } ?? .image
            let fileExtension = detectedType.preferredFilenameExtension ?? "img"
            let fileName = "photo_\(UUID().uuidString).\(fileExtension)"
            try await self.processData(data, fileType: detectedType, fileName: fileName)
        }
    }
}

// MARK: - Pasting
#if os(macOS)
extension InputManager {
    func handlePaste(pasteboardItem: NSPasteboardItem, supportedTypes: Set<UTType>) {
        Task { [weak self] in
            do {
                if let fileURLData = pasteboardItem.data(forType: .fileURL),
                   let fileURL = URL(dataRepresentation: fileURLData, relativeTo: nil) {
                    
                    // Check file size before processing
                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                    let fileSize = fileAttributes[.size] as? Int ?? 0
                    
                    guard fileSize <= Constants.maxFileSizeBytes else {
                        throw InputError.fileTooLarge(size: fileSize, maxSize: Constants.maxFileSizeBytes)
                    }
                    
                    let fileType = try fileURL.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier
                    if let fileUTType = fileType.flatMap({ UTType($0) }) {
                        if supportedTypes.contains(where: { fileUTType.conforms(to: $0) }) {
                            try await self?.processFile(at: fileURL)
                        }
                    }
                } else if let imageData = pasteboardItem.data(forType: .png) ?? pasteboardItem.data(forType: .tiff) {
                    // Check if images are supported
                    guard supportedTypes.contains(where: { $0.conforms(to: .image) }) else {
                        throw InputError.imageNotSupported
                    }

                    let fileType: UTType = pasteboardItem.data(forType: .png) != nil ? .png : .tiff
                    if let self {
                        try await self.processData(imageData, fileType: fileType, fileName: "Pasted_Image_\(UUID().uuidString).\(fileType.preferredFilenameExtension ?? "png")")
                    }
                } else if let pastedString = pasteboardItem.string(forType: .string) {
                    // Handle pasted plain text:
                    // If the pasted text is large (>= threshold) create a .txt file and add it as an attachment.
                    // Otherwise, do nothing here and allow the normal paste behavior (e.g., pasting into the text field).
                    let trimmed = pastedString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.count >= Constants.pasteTextToFileThreshold {
                        // Convert to data and create a .txt file
                        guard let textData = trimmed.data(using: .utf8) else {
                            throw InputError.unsupportedFileType
                        }

                        let fileType: UTType = .plainText
                        let fileName = "Paste_\(pastedString.prefix(7))_\(UUID().uuidString.prefix(2)).txt"

                        if let self {
                            try await self.processData(textData, fileType: fileType, fileName: fileName)
                        }
                    } else {
                        // Small text: do nothing here so that the default paste continues
                        // (PasteHandler will return false so the system inserts text into the focused text view)
                    }
                }
            } catch {
                print("Error processing paste: \(error)")
            }
        }
    }
}
#endif
