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
        
        let service = APIService.self
        let apiRequest = createAPIRequest(stream: true)
        
        for try await response in service.streamResponse(from: apiRequest) {
            switch response {
            case .text(let content):
                streamText += content
                await updateUIIfNeeded(streamText: streamText, lastUpdateTime: &lastUIUpdateTime)
            case .tool(let tool):
                assistant.toolCalls?.append(tool)
            case .finish(let tokens):
                totalTokens = calculateTotalTokens(tokens)
            case .error(let message):
                throw RuntimeError(message)
            }
        }
        
        finaliseStream(streamText: streamText, totalTokens: totalTokens)
    }
    
    @MainActor
    private func updateUIIfNeeded(streamText: String, lastUpdateTime: inout Date) async {
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
            #if os(macOS)
            AppConfig.shared.hasUserScrolled = false
            #else
            AppConfig.shared.hasUserScrolled = true
            #endif
        }
    }
    
    private func createAPIRequest(stream: Bool) -> APIRequest {
        let adjustedContext = chat.adjustedContext.dropLast() // removing last user msg
        let apiMessages = adjustedContext.map { $0.toAPIMessage() }
        
        return APIRequest(
            model: chat.config.model.id,
            messages: apiMessages,
            temperature: chat.config.temperature,
            maxTokens: chat.config.maxTokens.rawValue,
            system: chat.config.systemPrompt,
            stream: stream
        )
    }
    
    private func calculateTotalTokens(_ tokens: TokenUsage) -> Int {
        return tokens.promptTokens + tokens.completionTokens
    }
}
