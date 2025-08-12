//
//  MarkdownBackup.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct MarkdownBackup: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    
    private let chatTitle: String
    private let messageData: [(role: String, content: String, dataFiles: [String])]
    
    init(chat: Chat) {
        self.chatTitle = chat.title
        self.messageData = chat.currentThread.map { messageGroup in
            let message = messageGroup.activeMessage
            return (
                role: message.role.rawValue,
                content: message.content,
                dataFiles: message.dataFiles.map { $0.formattedTextContent }
            )
        }
    }
    
    init(configuration: ReadConfiguration) throws {
        print("Init with configuration")
        self.chatTitle = ""
        self.messageData = []
    }
    
    var markdown: String {
        var content = "# Chat Title: \(chatTitle)\n\n"
        
        for message in messageData {
            content += "## \(message.role.capitalized)\n"
            content += "\(message.dataFiles.joined(separator: "\n"))\n"
            content += "\(message.content)\n\n"
        }
        
        return content
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(markdown.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
