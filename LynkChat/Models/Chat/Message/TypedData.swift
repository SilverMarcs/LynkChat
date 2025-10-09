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

// TODO: see if can be simplified
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
    
    static func processDataFiles(_ dataFiles: [TypedData]) -> [Any] {
//        dataFiles.map { data in
//            if data.fileType.conforms(to: .text) {
//                return .text(data.formattedTextContent)
//            } else {
//                return .file(data: data.data, mimeType: data.mimeType)
//            }
//        }
        return []
    }
}

extension UTType {
    var fileExtension: String {
        self.preferredFilenameExtension ?? "dat"
    }
}
