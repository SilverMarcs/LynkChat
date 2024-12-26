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
        chat.config.provider.host = chat.config.provider.host.trimmingCharacters(in: .whitespacesAndNewlines)
        if chat.config.stream {
            try await handleStream()
        } else {
            try await handleNonStream()
        }
    }
    
    @MainActor
    private func handleStream() async throws {
        var streamText = ""
        var lastUIUpdateTime = Date()
        var totalTokens = 0

        // TODO: unify into own func for both stream non stream
        let config = chat.config
        
        let adjustedContext: [Message] = chat.adjustedContext.dropLast() // removing las user msg
        let apiMessages: [APIMessage] = adjustedContext.map { $0.toAPIMessage() }
        let apiRequest: APIRequest = .init(provider: config.provider.type.rawValue, model: config.model.code, messages: apiMessages, stream: true, customBaseUrl: config.provider.host, customApiKey: config.provider.apiKey)
        
        for try await response in APIService.streamResponse(from: apiRequest) {
            switch response {
            case .content(let content):
                streamText += content
                
                let currentTime = Date()
                if currentTime.timeIntervalSince(lastUIUpdateTime) >= Float.UIIpdateInterval {
                    assistant.content = streamText
//                    scrollDown()
                    lastUIUpdateTime = currentTime
                }
            case .totalTokens(let tokens):
                // TODO: collect statistics
                totalTokens = tokens.inputTokens + tokens.outputTokens
            }
        }

        finaliseStream(streamText: streamText, totalTokens: totalTokens)
    }
    
    private func finaliseStream(streamText: String = "", totalTokens: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Float.UIIpdateInterval) {
            chat.totalTokens = totalTokens > 0 ? totalTokens : chat.totalTokens
            assistant.content = streamText
            assistant.isReplying = false
//            scrollDown()
            try? assistant.modelContext?.save()
            #if os(macOS)
            AppConfig.shared.hasUserScrolled = false
            #else
            AppConfig.shared.hasUserScrolled = true
            #endif
        }
    }

    @MainActor
    private func handleNonStream() async throws {
//        let service = chat.config.provider.type.getService()
        let config = chat.config
        
        let adjustedContext: [Message] = chat.adjustedContext.dropLast() // removing las user msg
        let apiMessages: [APIMessage] = adjustedContext.map { $0.toAPIMessage() }
        let apiRequest: APIRequest = .init(provider: config.provider.type.rawValue, model: config.model.code, messages: apiMessages, stream: false, customBaseUrl: config.provider.host, customApiKey: config.provider.apiKey)
        
        let response = try await APIService.nonStreamingResponse(from: apiRequest)
        
        if let content = response.content {
            assistant.content = content
        }
        
        let tokens = response.inputTokens + response.outputTokens
        
        chat.totalTokens = tokens > 0 ? tokens : chat.totalTokens
        assistant.isReplying = false
//        scrollDown()
        AppConfig.shared.hasUserScrolled = false
        try? assistant.modelContext?.save()
    }

    private func scrollDown() {
        chat.scrollDown()
    }
}
