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
                do {
                    let secondaryMessage = Message.assistant(model: model)
                    assistantGroup.addMessage(secondaryMessage)
                    
                    let secondaryHandler = StreamHandler(chat: chat, assistant: secondaryMessage, user: user)
                    try await secondaryHandler.handleRequest()
                } catch {
                    // Handle individual stream errors gracefully
                    AppLogger.error("Secondary stream error for model \(model.name): \(error)")
                }
            }
        }
        
        // Wait for all tasks to complete
        try await primaryTask.value
        
        // Wait for all secondary tasks
        for task in secondaryTasks {
            await task.value
        }
        
        finishResponse()
    }
    
    // MARK: - Helper Methods
    
    private func createAPIRequest() async -> APIRequest {
        let adjustedContext = chat.adjustedContext.dropLast() // removing last assistant msg
        let apiMessages = adjustedContext.map { $0.toAPIMessage() }
        return createAPIRequest(with: apiMessages)
    }
    
    private func createAPIRequest(with messages: [APIMessage]) -> APIRequest {
        let date = "Today's date is \(Date().formatted(date: .complete, time: .omitted))"
        
        return APIRequest(
            userId: "zabir",
            model: AppConfig.shared.sendDebugModel ? "debug" : chat.config.model.id,
            messages: messages,
            temperature: chat.config.temperature.value,
            thinkingBudget: chat.config.thinkingBudget.rawValue,
            system: date + "\n" + chat.config.systemPrompt + "\n" + String.toolExtras + chat.config.enabledTools.map { $0.toolPrompt }.joined(separator: "\n"),
            tools: chat.config.enabledTools.map { $0.rawValue }
        )
    }
    
    private func finishResponse() {
        withAnimation(.easeInOut(duration: 1)) { 
            AppSettings.shared.expandColor = false 
        }
    }
}
