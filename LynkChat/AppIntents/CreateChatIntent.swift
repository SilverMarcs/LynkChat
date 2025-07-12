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
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Ensure we have a valid message
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            throw CreateChatError.emptyMessage
        }
        
        // Create new chat
        let newChat = ChatVM.shared.createNewChat(delay: true)
        
        try? await Task.sleep(for: .seconds(0.1)) // Optional delay for better UX
        
        await newChat.sendInput(prompt: trimmedMessage)
        
        try await continueInForeground(alwaysConfirm: false)
        
        return .result()
    }
}

enum CreateChatError: Error, LocalizedError {
    case chatVMNotAvailable
    case emptyMessage
    
    var errorDescription: String? {
        switch self {
        case .chatVMNotAvailable:
            return "Chat system is not available"
        case .emptyMessage:
            return "Please provide a message for the chat"
        }
    }
}
