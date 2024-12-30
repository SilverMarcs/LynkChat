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
    private enum Constants {
        static let maxFileSizeBytes: Int = 5 * 1024 * 1024 // 5MB in bytes
    }
    
    func processData(_ data: Data, fileType: UTType? = nil, fileName: String? = nil, url: URL? = nil) async throws {
        // Check file size first
        guard data.count <= Constants.maxFileSizeBytes else {
            throw InputError.fileTooLarge(size: data.count, maxSize: Constants.maxFileSizeBytes)
        }
        
        let fileURL = url ?? URL(fileURLWithPath: fileName ?? "Unknown")
        let fileType = fileType ?? (try? fileURL.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier).flatMap { UTType($0) } ?? .data
        let fileName = fileName ?? fileURL.deletingPathExtension().lastPathComponent + "." + fileType.fileExtension

        let typedData = TypedData(
            data: data,
            fileType: fileType,
            fileName: fileName
        )
    
        await MainActor.run {
            // Remove existing file with the same name, if any
            if let existingIndex = self.dataFiles.firstIndex(where: { $0.fileName == fileName }) {
                self.dataFiles.remove(at: existingIndex)
            }

            withAnimation {
                self.dataFiles.insert(typedData, at: 0)
            }
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

// Update the error enum to include more detailed information
enum InputError: LocalizedError {
    case fileTooLarge(size: Int, maxSize: Int)
    case unsupportedAudioFormat
    case unsupportedFileType
    
    var errorDescription: String? {
        switch self {
        case .fileTooLarge(let size, let maxSize):
            return "File size (\(formatFileSize(size))) exceeds maximum allowed size (\(formatFileSize(maxSize)))"
        case .unsupportedAudioFormat:
            return "Unsupported audio format"
        case .unsupportedFileType:
            return "Unsupported file type"
        }
    }
    
    // Helper function to format file sizes in human-readable format
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB, .useBytes]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

extension InputManager {
    func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            // First, get the file name using loadFileRepresentation
            provider.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { url, _ in
                guard let url = url else { return }
                
                // Check file size before proceeding
                guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                      let fileSize = fileAttributes[.size] as? Int,
                      fileSize <= Constants.maxFileSizeBytes else {
                    print("File size exceeds 5MB limit")
                    return
                }
                
                let fileName = url.lastPathComponent
                let typeIdentifier = provider.registeredTypeIdentifiers.first
                
                provider.loadDataRepresentation(forTypeIdentifier: UTType.item.identifier) { data, error in
                    guard let data = data else {
                        print("Failed to load data representation")
                        return
                    }
                    
                    Task {
                        do {
                            let fileType = typeIdentifier.flatMap { UTType($0) } ?? .data
                            try await self.processData(data, fileType: fileType, fileName: fileName)
                        } catch {
                            print("Failed to process file: \(fileName). Error: \(error)")
                        }
                    }
                }
            }
        }
        
        return !providers.isEmpty
    }
    
    func loadTransferredPhotos(from selectedPhotos: [PhotosPickerItem]) async {
        for photo in selectedPhotos {
            if let data = try? await photo.loadTransferable(type: Data.self) {
                // Check file size
                guard data.count <= Constants.maxFileSizeBytes else {
                    print("Photo exceeds 5MB limit")
                    continue
                }
                
                let fileName = "photo_\(UUID().uuidString).jpg"
                
                do {
                    try await self.processData(data, fileType: .jpeg, fileName: fileName)
                } catch {
                    print("Failed to process photo: \(fileName). Error: \(error)")
                }
            }
        }
    }
}

#if os(macOS)
extension InputManager {
    func handlePaste(pasteboardItem: NSPasteboardItem) {
        Task {
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
                        if fileUTType.conforms(to: .text) ||
                           fileUTType.conforms(to: .pdf) ||
                           fileUTType.conforms(to: .audio) {
                            try await processFile(at: fileURL)
                        }
                    }
                    
                } else if let imageData = pasteboardItem.data(forType: .png) ?? pasteboardItem.data(forType: .tiff) {
                    guard imageData.count <= Constants.maxFileSizeBytes else {
                        throw InputError.fileTooLarge(size: imageData.count, maxSize: Constants.maxFileSizeBytes)
                    }
                    try await processData(imageData, fileType: .png, fileName: "Pasted_Image_\(UUID().uuidString).png")
                }
            } catch {
                print("Error processing paste: \(error)")
            }
        }
    }
}
#endif
