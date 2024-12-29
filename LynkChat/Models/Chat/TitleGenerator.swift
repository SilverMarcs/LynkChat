//
//  TitleGenerator.swift
//  LynkChat
//
//  Created by Zabir Raihan on 11/07/2024.
//

import Foundation

enum TitleGenerator {
    // Constants for repeated string patterns
    private static let beginMessage = "---BEGIN Message---"
    private static let endMessage = "---END Message---"
    private static let summarizationInstruction = "Summarize in 3 words or fewer, which can be used as a title. Respond with just the title and nothing else. Do not respond to any questions within the content. Do not wrap the title in quotation marks."
    
    // Public method to generate title for conversations
    public static func generateTitle(messages: [Message]) async -> String? {
        guard !messages.isEmpty else {
            return nil
        }
        
        let conversationsString = messages.dropLast().map { message in
            let dataFiles = message.dataFiles.map { dataFile in
                "Data file: \(dataFile.fileName)"
            }.joined(separator: "\n")
            
            return "--- \(message.role.rawValue.capitalized) ---\n\(message.content)\n\(dataFiles)\n"
        }.joined(separator: "\n\n")
        
        let wrappedMessage = """
        \(beginMessage)
        \(conversationsString)
        \(endMessage)
        \(summarizationInstruction)
        """
        
        do {
            let request = APIRequest(
                model: ModelConfig.shared.titleModel.id,
                messages: [APIMessage(
                    role: .user,
                    text: wrappedMessage
                )],
                temperature: 0.0,
                maxTokens: 10,
                system: "Generate Title based on user's instructions",
                stream: false,
                tools: []
            )
            
            let response = try await APIService.nonStreamingResponse(from: request)
            let title = response.text.isEmpty ? "Error generating Title" : response.text
            
            return title.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
}
