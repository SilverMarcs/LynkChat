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
        static let maxTotalFiles: Int = 5
        static let maxAudioFiles: Int = 1
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
        
        // Check total file limit
        if dataFiles.count >= Constants.maxTotalFiles {
            throw InputError.tooManyFiles(current: dataFiles.count, max: Constants.maxTotalFiles)
        }
        
        // Check audio file limit
        if fileType.conforms(to: .audio) {
            let existingAudioFiles = dataFiles.filter { $0.fileType.conforms(to: .audio) }
            if existingAudioFiles.count >= Constants.maxAudioFiles {
                throw InputError.tooManyAudioFiles(max: Constants.maxAudioFiles)
            }
        }
        
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

extension InputManager {
    func handleDrop(_ providers: [NSItemProvider]) throws -> Bool {
        guard !providers.isEmpty else { return false }
        
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
                        let fileType = typeIdentifier.flatMap { UTType($0) } ?? .data
                        try await self.processData(data, fileType: fileType, fileName: fileName)
                    }
                }
            }
        }
        
        return true
    }
    
    func loadTransferredPhotos(from selectedPhotos: [PhotosPickerItem]) async throws {
        for photo in selectedPhotos {
            guard let data = try? await photo.loadTransferable(type: Data.self) else {
                throw RuntimeError("Failed to load photo data")
            }
            
            // Check file size
            guard data.count <= Constants.maxFileSizeBytes else {
                throw InputError.fileTooLarge(size: data.count, maxSize: Constants.maxFileSizeBytes)
            }
            
            let fileName = "photo_\(UUID().uuidString).jpg"
            try await self.processData(data, fileType: .jpeg, fileName: fileName)
        }
    }
}

#if os(macOS)
extension InputManager {
    func handlePaste(pasteboardItem: NSPasteboardItem, supportedTypes: Set<UTType>) {
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
                          if supportedTypes.contains(where: { fileUTType.conforms(to: $0) }) {
                              try await processFile(at: fileURL)
                          }
                      }
                  } else if let imageData = pasteboardItem.data(forType: .png) ?? pasteboardItem.data(forType: .tiff) {
                      // Check if images are supported
                      guard supportedTypes.contains(where: { $0.conforms(to: .image) }) else {
                          throw InputError.imageNotSupported
                      }
                      
                      // Existing size check...
                      try await processData(imageData, fileType: .png, fileName: "Pasted_Image_\(UUID().uuidString).png")
                  }
            } catch {
                print("Error processing paste: \(error)")
            }
        }
    }
}
#endif
