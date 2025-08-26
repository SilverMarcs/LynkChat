//
//  CreateChatIntent.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/06/2025.
//

import AppIntents
import Foundation

struct CreateChatIntent: AppIntent {
    static var title: LocalizedStringResource = "Create New Chat"
    static var description = IntentDescription("Create a new chat with your prompt")
    
    static var supportedModes: IntentModes = [.foreground(.dynamic)]
    static var isDiscoverable: Bool = true
    
    @Parameter(
        title: "Prompt",
        description: "Your prompt to start the chat with",
        requestValueDialog: "What would you like to ask AI?"
    )
    var message: String
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
