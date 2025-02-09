//
//  TypedData.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/08/2024.
//

import SwiftData
import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct TypedData: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var data: Data
    var fileType: UTType
    var fileName: String
    
    private var textContent: String? {
        if fileType.conforms(to: .text) {
            return String(data: data, encoding: .utf8) ?? "Unable to read text file content"
        }
        return nil
    }
    
    var formattedTextContent: String {
        guard fileType.conforms(to: .text),
              let content = textContent else { 
            return "Non-text file: \(fileName)" 
        }
        return "\(fileName)\n\(content)\n"
    }
    
    var mimeType: String {
        return fileType.preferredMIMEType ?? "application/octet-stream"
    }
    
    var imageName: PlatformImage {
        #if os(macOS)
        NSWorkspace.shared.icon(for: self.fileType)
        #else
        PlatformImage(systemName: "doc.on.doc.fill")!
        #endif
    }
    
    static func processDataFiles(_ dataFiles: [TypedData]) -> [ContentItem] {
        var contentItems: [ContentItem] = []
        
        for data in dataFiles {
            if data.fileType.conforms(to: .text) {
                contentItems.append(.text(data.formattedTextContent))
            } else if data.fileType.conforms(to: .image) {
                contentItems.append(.image(mimeType: data.mimeType, data: data.data))
            } else {
                // Send non-text, non-image files as raw data
                contentItems.append(.file(mimeType: data.mimeType, data: data.data, fileName: data.fileName))
            }
        }
        
        return contentItems
    }
}

extension UTType {
    var fileExtension: String {
        self.preferredFilenameExtension ?? "dat"
    }
}
