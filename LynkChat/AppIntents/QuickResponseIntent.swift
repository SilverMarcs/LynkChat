//
//  QuickResponseIntent.swift
//  LynkChat
//
//  Created by Zabir Raihan on 22/06/2025.
//

import AppIntents
import SwiftUI

struct QuickResponseIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick AI Response"
    static var description = IntentDescription("Get a quick response from AI without opening the app")
    
    static var supportedModes: IntentModes = [.background]
    static var isDiscoverable: Bool = true
    
    @Parameter(
        title: "Prompt",
        description: "Your question or prompt for AI",
        requestValueDialog: "What would you like to ask AI?"
    )
    var prompt: String
    
    func perform() async throws -> some IntentResult & ShowsSnippetIntent & ProvidesDialog {
        // Ensure we have a valid prompt
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else {
            throw QuickResponseError.emptyPrompt
        }
        
        // Create dialog for voice-only experiences - immediate response
        let dialog = IntentDialog(
            full: "Getting AI response for your question...",
            supporting: "LynkChat Response"
        )
        
        // Return immediately with loading snippet - no delay
        return .result(
            dialog: dialog,
            snippetIntent: QuickResponseSnippetIntent(prompt: trimmedPrompt, response: nil)
        )
    }
}

// Simplified Snippet Intent to display the response
struct QuickResponseSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "Quick Response Snippet"
    
    @Parameter var prompt: String
    @Parameter var response: String?
    
    init() {
        self.prompt = ""
        self.response = nil
    }
    
    init(prompt: String, response: String?) {
        self.prompt = prompt
        self.response = response
    }
    
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        // If response is nil, we need to fetch it (loading state)
        if response == nil {
            // Get the response and create a new snippet intent with the result
            let aiResponse = await TitleGenerator.quickResponse(prompt: prompt)
            
            // Return updated snippet with the response
            return .result(
                view: VStack(alignment: .leading) {
                    Text(aiResponse)
                        .font(.caption)
                        .frame(alignment: .leading)
                }
//                .padding(4)
                .padding(.top, 8)
            )
        } else {
            // We already have the response
            return .result(
                view: VStack(alignment: .leading) {
                    Text(response!)
                        .font(.caption)
                        .frame(alignment: .leading)
                }
//                .padding(4)
                .padding(.top, 8)
            )
        }
    }
}

// Error handling
enum QuickResponseError: Error, LocalizedError {
    case emptyPrompt
    case responseGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .emptyPrompt:
            return "Please provide a question or prompt for AI"
        case .responseGenerationFailed:
            return "Failed to generate AI response"
        }
    }
}
