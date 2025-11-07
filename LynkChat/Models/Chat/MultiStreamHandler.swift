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
        } else {
            // Multiple models - handle concurrently
            let primaryMessage = assistantGroup.activeMessage
            let secondaryModels = models.dropFirst() // All models except the first one
            
            // Start primary stream
            let primaryTask = Task {
                let primaryHandler = StreamHandler(chat: chat, assistant: primaryMessage, user: user)
                try await primaryHandler.handleRequest()
            }
            
            // Start secondary streams concurrently
            let secondaryTasks = secondaryModels.map { model in
                Task {
                    let secondaryMessage = Message.assistant(model: model)
                    assistantGroup.addMessage(secondaryMessage, skipActive: true)
                    
                    let secondaryHandler = StreamHandler(chat: chat, assistant: secondaryMessage, user: user)
                    try await secondaryHandler.handleRequest()
                }
            }
            
            // Wait for all tasks to complete
            try await primaryTask.value
            
            // Wait for all secondary tasks
            for task in secondaryTasks {
                try await task.value
            }
        }
    }
}
