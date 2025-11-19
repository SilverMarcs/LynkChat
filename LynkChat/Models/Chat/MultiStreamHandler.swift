//
//  MultiStreamHandler.swift
//  LynkChat
//
//  Created by GitHub Copilot on 28/08/2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct MultiStreamHandler {
    let chat: Chat
    let assistantGroup: MessageGroup
    let user: Message
    
    func handleMultipleRequests() async throws {
        let models = Array(chat.config.models)
        
        if models.count == 1 {
            // Single model - use the existing active message
            let primaryMessage = assistantGroup.activeMessage
            let primaryHandler = StreamHandler(chat: chat, assistant: primaryMessage, user: user)
            try await primaryHandler.handleRequest()
            return
        }
        
        let primaryMessage = assistantGroup.activeMessage
        let secondaryModels = Array(models.dropFirst())
        let secondaryMessages = secondaryModels.map { model -> Message in
            let secondaryMessage = Message.assistant(model: model)
            assistantGroup.addMessage(secondaryMessage, skipActive: true)
            return secondaryMessage
        }
        
        let primaryTask = Task {
            let handler = StreamHandler(chat: chat, assistant: primaryMessage, user: user)
            try await handler.handleRequest()
        }
        
        let secondaryTasks = secondaryMessages.map { message in
            Task {
                let handler = StreamHandler(chat: chat, assistant: message, user: user)
                try await handler.handleRequest()
            }
        }
        
        try await primaryTask.value
        for task in secondaryTasks {
            try await task.value
        }
    }
}
