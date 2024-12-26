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
        } else if fileType.conforms(to: .pdf) {
            return PDFDocument(data: data)?.string ?? "Unable to read PDF content"
        }
        return nil
    }
    
    var formattedTextContent: String {
        guard let content = textContent else { return "Unable to read file content for \(fileName). Notify the user" }
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
}

extension UTType {
    var fileExtension: String {
        self.preferredFilenameExtension ?? "dat"
    }
}
