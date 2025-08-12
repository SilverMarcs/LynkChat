//
//  StreamHandler.swift
//  LynkChat
//
//  Created by Zabir Raihan on 16/09/2024.
//

import Foundation
import SwiftUI

struct StreamHandler {
    let chat: Chat
    let assistant: Message
    
    func handleRequest() async throws {
        chat.isReplying = true // Set isReplying to true when streaming starts
        var streamText = ""
        var reasoning = ""
        var totalTokens = 0
        
        let apiRequest = await createAPIRequest()
        
        AppSettings.shared.expandColor = true
        Scroller.scrollToBottom()
        
        for try await response in APIService.streamResponse(from: apiRequest) {
            switch response {
            case .text(let textResponse):
                streamText += textResponse.content
                assistant.content = streamText

            case .reasoning(let reasoningResponse):
                chat.isReasoning = true
                reasoning += reasoningResponse.reasoning
                assistant.reasoning = reasoning

            case .reasoningEnd(_):
                chat.isReasoning = false

            case .toolCall(let toolCallResponse):
                updateTools(with: toolCallResponse)

            case .toolResult(let toolResultResponse):
                updateToolResult(for: toolResultResponse)

            case .finish(let finishResponse):
                totalTokens = finishResponse.totalTokens

            case .error(let errorResponse):
                throw RuntimeError(errorResponse.content)
            }
        }
        
        finaliseStream(streamText: streamText, totalTokens: totalTokens)
    }
    
    private func finaliseStream(streamText: String = "", totalTokens: Int) {
        chat.isReplying = false
        chat.totalTokens = totalTokens > 0 ? totalTokens : chat.totalTokens
        
        // Check if the message should be kept - either has text content or has tools with results
        let hasValidTools = assistant.tools?.contains { $0.result != nil } ?? false
        let shouldKeepMessage = !streamText.isEmpty || hasValidTools
        
        if shouldKeepMessage {
            // Normal case - update the content and keep the message
            assistant.content = streamText
            assistant.isReplying = false
            try? assistant.modelContext?.save()
        } else {
            // Handle empty message with no tool results
            if let lastGroup = chat.currentThread.last,
               lastGroup.allMessages.count > 1 {
                // This was likely a regeneration - delete only this message and set previous as active
                lastGroup.deleteAndSetPreviousActive()
            } else {
                // This was a new message group - delete the entire last message
                chat.errorDeleteLast()
            }
        }
        
        withAnimation(.easeInOut(duration: 1)) {
            AppSettings.shared.expandColor = false
        }
    }
    
    private func createAPIRequest() async -> APIRequest {
        let adjustedContext = chat.adjustedContext.dropLast() // removing last user msg
        let apiMessages = adjustedContext.map { $0.toAPIMessage() }
        let date = "Today's date is \(Date().formatted(date: .complete, time: .omitted))"
        
        return APIRequest(
            userId: "zabir",
            model: AppConfig.shared.sendDebugModel ? "debug" : chat.config.model.id,
            messages: apiMessages,
            temperature: chat.config.temperature.value,
            thinkingBudget: chat.config.thinkingBudget.rawValue,
//            maxTokens: chat.config.maxTokens.rawValue,
            system: date + "\n" + chat.config.systemPrompt + "\n" + String.toolExtras + chat.config.enabledTools.map { $0.toolPrompt }.joined(separator: "\n"),
            tools: chat.config.model.supportsTool ? chat.config.enabledTools.map { $0.rawValue } : []
        )
    }
    
    private func updateTools(with toolCallResponse: ToolCallResponse) {
        assistant.tools?.append(.init(
            toolCallId: toolCallResponse.toolCallId,
            tool: toolCallResponse.tool,
            args: toolCallResponse.args,
            result: nil
        ))
    }

    private func updateToolResult(for toolResultResponse: ToolResultResponse) {
        if let index = assistant.tools?.firstIndex(where: { $0.toolCallId == toolResultResponse.toolCallId }) {
            assistant.tools?[index].result = toolResultResponse.result
        }
    }
}
