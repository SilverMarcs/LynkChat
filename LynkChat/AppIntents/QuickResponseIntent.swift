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
        
        // Get the AI response directly
        let response = await TitleGenerator.quickResponse(prompt: trimmedPrompt)
        
        // Create dialog for voice-only experiences
        let dialog = IntentDialog(
            full: "\(response)",
            supporting: "AI response"
        )
        
        return .result(
            dialog: dialog,
            snippetIntent: QuickResponseSnippetIntent(prompt: trimmedPrompt, response: response)
        )
    }
}

// Simplified Snippet Intent to display the response
struct QuickResponseSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "Quick Response Snippet"
    
    @Parameter var prompt: String
    @Parameter var response: String
    
    init() {
        self.prompt = ""
        self.response = ""
    }
    
    init(prompt: String, response: String) {
        self.prompt = prompt
        self.response = response
    }
    
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(
            view:
                VStack(alignment: .leading) {
                    Text(response)
                        .font(.caption)
                    
                    Button {
                        response.copyToPasteboard()
                    } label: {
                        Label("Copy Response", systemImage: "doc.on.doc")
                            .foregroundStyle(.blue)
                            .labelStyle(.iconOnly)
                    }
                }
                .padding(5)
        )
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
