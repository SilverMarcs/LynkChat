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

    init(chat: Chat, assistant: Message) {
        self.chat = chat
        self.assistant = assistant
    }

    @MainActor
    func handleRequest() async throws {
        var streamText = ""
        var lastUIUpdateTime = Date()
        var totalTokens = 0
        
        AppConfig.shared.expandColor = true
        Scroller.scrollToBottom()
        Scroller.scrollToBottom()
        
        let apiRequest = await createAPIRequest(stream: true)
        
        for try await response in APIService.self.streamResponse(from: apiRequest) {
            switch response {
            case .text(let textResponse):
                streamText += textResponse.content
                updateUIIfNeeded(streamText: streamText, lastUpdateTime: &lastUIUpdateTime)
                
            case .toolCall(let toolCallResponse):
                assistant.tools?.append(.init(
                    toolCallId: toolCallResponse.toolCallId,
                    tool: toolCallResponse.tool,
                    args: toolCallResponse.args,
                    result: nil
                ))
                
            case .toolResult(let toolResultResponse):
                if let index = assistant.tools?.firstIndex(where: { $0.toolCallId == toolResultResponse.toolCallId }) {
                    assistant.tools?[index].result = toolResultResponse.result
                }
                
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
    private func updateUIIfNeeded(streamText: String, lastUpdateTime: inout Date) {
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastUpdateTime) >= Float.UIIpdateInterval {
            assistant.content = streamText
            lastUpdateTime = currentTime
        }
    }
    
    private func finaliseStream(streamText: String = "", totalTokens: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Float.UIIpdateInterval) {
            chat.totalTokens = totalTokens > 0 ? totalTokens : chat.totalTokens
            assistant.content = streamText
            assistant.isReplying = false
            try? assistant.modelContext?.save()
            withAnimation {
                AppConfig.shared.expandColor = false
            }
        }
    }
    
    private func createAPIRequest(stream: Bool) async -> APIRequest {
        let adjustedContext = chat.adjustedContext.dropLast() // removing last user msg
        let apiMessages = await adjustedContext.asyncMap { await $0.toAPIMessage() }
        let date = "Today's date is \(Date().formatted(date: .complete, time: .omitted))"
        
        return APIRequest(
            model: AppConfig.shared.sendDebugModel ? "debug" : chat.config.model.id,
            messages: apiMessages,
            temperature: chat.config.temperature,
            maxTokens: chat.config.maxTokens.rawValue,
            system: date + "\n" + chat.config.systemPrompt + "\n" + chat.config.enabledTools.map { $0.toolPrompt }.joined(separator: "\n"),
            stream: stream,
            tools: chat.config.model.supportsTool ? chat.config.enabledTools.map { $0.rawValue } : []
        )
    }
    
    func calculateTotalTokens(promptTokens: Int, completionTokens: Int) -> Int {
        // New implementation using direct token values
        return promptTokens + completionTokens // or whatever calculation you need
    }
}
