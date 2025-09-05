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
        AppSettings.shared.expandColor = true
        Scroller.scrollToBottom()
        
        let primaryMessage = assistantGroup.activeMessage
        let secondaryModels = chat.config.secondaryModels
        
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
