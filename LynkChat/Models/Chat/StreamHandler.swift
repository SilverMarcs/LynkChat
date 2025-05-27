//
//  StreamHandler.swift
//  LynkChat
//
//  Created by Zabir Raihan on 16/09/2024.
//

import Foundation
import SwiftUI

struct StreamHandler {
    private let chat: Chat
    private var assistant: Message
    private let toolsLock = NSLock() // Add this lock
    
    init(chat: Chat, assistant: Message) {
        self.chat = chat
        self.assistant = assistant
    }

    @MainActor
    func handleRequest() async throws {
        var streamText = ""
        var reasoning = ""
        var lastUIUpdateTime = Date()
        var totalTokens = 0
        
        AppConfig.shared.expandColor = true
        Scroller.scrollToBottom(delay: 0.3)
        
        let apiRequest = await createAPIRequest()
        
        for try await response in APIService.streamResponse(from: apiRequest) {
            switch response {
            case .text(let textResponse):
                streamText += textResponse.content
                updateUIIfNeeded(streamText: streamText, reasoning: reasoning, lastUpdateTime: &lastUIUpdateTime)
                
            case .reasoning(let reasoningResponse):
                reasoning += reasoningResponse.reasoning
                updateUIIfNeeded(streamText: streamText, reasoning: reasoning, lastUpdateTime: &lastUIUpdateTime)
                
            case .toolCall(let toolCallResponse):
                updateTools(with: toolCallResponse)
                
            case .toolResult(let toolResultResponse):
                updateToolResult(for: toolResultResponse)
                
            case .finish(let finishResponse):
                totalTokens = calculateTotalTokens(
                    promptTokens: finishResponse.promptTokens,
                    completionTokens: finishResponse.completionTokens
                )
                
            case .error(let errorResponse):
                throw RuntimeError(errorResponse.content)
            }
        }
        
        finaliseStream(streamText: streamText, totalTokens: totalTokens)
    }
    
    @MainActor
    private func updateUIIfNeeded(streamText: String, reasoning: String, lastUpdateTime: inout Date) {
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastUpdateTime) >= Float.UIIpdateInterval {
            assistant.content = streamText
            assistant.reasoning = reasoning
            lastUpdateTime = currentTime
        }
    }
    
    private func finaliseStream(streamText: String = "", totalTokens: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Float.UIIpdateInterval) {
            chat.totalTokens = totalTokens > 0 ? totalTokens : chat.totalTokens
            
            // Check if the message content is empty after streaming completes
            if streamText.isEmpty {
                // Handle empty message
                if let lastGroup = chat.currentThread.last,
                   lastGroup.allMessages.count > 1 {
                    // This was likely a regeneration - delete only this message and set previous as active
                    lastGroup.deleteAndSetPreviousActive()
                } else {
                    // This was a new message group - delete the entire last message
                    chat.errorDeleteLast()
                }
            } else {
                // Normal case - update the content
                assistant.content = streamText
                assistant.isReplying = false
                try? assistant.modelContext?.save()
            }
            
            withAnimation(.easeInOut(duration: 0.5)) {
                AppConfig.shared.expandColor = false
            }
        }
    }
    
    private func createAPIRequest() async -> APIRequest {
        let adjustedContext = chat.adjustedContext.dropLast() // removing last user msg
        let apiMessages = await adjustedContext.asyncMap { $0.toAPIMessage() }
        let date = "Today's date is \(Date().formatted(date: .complete, time: .omitted))"
        
        return APIRequest(
            userId: "zabir",
            model: AppConfig.shared.sendDebugModel ? "debug" : chat.config.model.id,
            messages: apiMessages,
            temperature: chat.config.temperature.value,
            maxTokens: chat.config.maxTokens.rawValue,
            system: date + "\n" + chat.config.systemPrompt + "\n" + String.toolExtras + chat.config.enabledTools.map { $0.toolPrompt }.joined(separator: "\n"),
            tools: chat.config.model.supportsTool ? chat.config.enabledTools.map { $0.rawValue } : []
        )
    }
    
    func calculateTotalTokens(promptTokens: Int, completionTokens: Int) -> Int {
        // New implementation using direct token values
        return promptTokens + completionTokens // or whatever calculation you need
    }
    
    private func updateTools(with toolCallResponse: ToolCallResponse) {
        toolsLock.lock()
        defer { toolsLock.unlock() }
        
        assistant.tools?.append(.init(
            toolCallId: toolCallResponse.toolCallId,
            tool: toolCallResponse.tool,
            args: toolCallResponse.args,
            result: nil
        ))
    }

    private func updateToolResult(for toolResultResponse: ToolResultResponse) {
        toolsLock.lock()
        defer { toolsLock.unlock() }
        
        if let index = assistant.tools?.firstIndex(where: { $0.toolCallId == toolResultResponse.toolCallId }) {
            assistant.tools?[index].result = toolResultResponse.result
        }
    }
}
