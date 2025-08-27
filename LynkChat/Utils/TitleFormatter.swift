//
//  TitleFormatter.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/08/2025.
//

import Foundation

nonisolated enum TitleFormatter {
    // Public method to format messages for title generation
    static func formatMessagesForTitleGeneration(messages: [Message]) -> String {
        let conversationsString = messages.map { message in
            let dataFiles = message.dataFiles.map { dataFile in
                "Data file: \(dataFile.fileName)"
            }.joined(separator: "\n")
            
            return "--- \(message.role.rawValue.capitalized) ---\n\(message.content)\n\(dataFiles)\n"
        }.joined(separator: "\n\n")
        
        return """
        \("---BEGIN Message---")
        \(conversationsString)
        \("---END Message---")
        """
    }
}
