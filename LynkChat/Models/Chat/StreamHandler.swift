//
//  StreamHandler.swift
//  LynkChat
//
//  Created by Zabir Raihan on 16/09/2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct StreamHandler {
    let chat: Chat
    let assistant: Message
    let user: Message
    
    func handleRequest() async throws {
        AppSettings.shared.expandColor = true
        Scroller.scrollToBottom()
        
        try await processStreamWithOpenAI()
        
        finishResponse()
    }
    
    // MARK: - Stream Processing with OpenAI Client
    
    private func processStreamWithOpenAI() async throws {
        // Local buffers for batching updates
        var contentBuffer = ""
        var reasoningBuffer = assistant.reasoning ?? ""
        
        // Timer for periodic updates
        let updateInterval: TimeInterval = 0.2
        var lastUpdateTime = Date()
        
        // Helper function to update UI
        func updateUI() {
            assistant.content = contentBuffer
            assistant.reasoning = reasoningBuffer.isEmpty ? nil : reasoningBuffer
        }
        
        // Create OpenAI client
        let model = chat.config.model
        let client = OpenAIClient(
            apiKey: model.apiKey,
            baseURL: model.baseURL,
            model: model.id
        )
        
        // Prepare messages
        let adjustedContext = chat.adjustedContext.dropLast() // removing last user msg
        // Filter out assistant messages with empty content (these are local messages being updated)
        let messages = adjustedContext
            .filter { !($0.role == .assistant && $0.content.isEmpty) }
            .map { $0.toChatRequestMessage() }
        
        // Add system message with date
        let date = "Today's date is \(Date().formatted(date: .complete, time: .omitted))"
        let systemMessage = ChatRequestMessage(
            role: .system,
            content: [MessageContent(text: date + "\n" + chat.config.systemPrompt)]
        )
        let allMessages = [systemMessage] + messages
        
        // Stream chat completion
        // Note: MCP servers are not yet supported, passing empty tools array
        let stream = client.streamChatCompletion(
            messages: allMessages,
            temperature: chat.config.temperature.value,
            maxTokens: nil,
            tools: nil,
            thinkingBudget: chat.config.thinkingBudget
        )
        
        for try await response in stream {
            guard let choice = response.choices.first else { continue }
            
            // Handle content
            if let content = choice.delta.content {
                contentBuffer += content
            }
            
            // Handle reasoning
            if let reasoning = choice.delta.reasoning {
                reasoningBuffer += reasoning
            }
            
            // Handle usage tokens (only comes at the end with finish_reason)
            if let usage = response.usage {
                if let promptTokens = usage.prompt_tokens {
                    user.inputTokens = promptTokens
                }
                if let completionTokens = usage.completion_tokens {
                    assistant.outputTokens = completionTokens
                }
                if let reasoningTokens = usage.completion_tokens_details?.reasoning_tokens {
                    assistant.reasoningTokens = reasoningTokens
                }
            }
            
            // Periodic UI updates
            let now = Date()
            if now.timeIntervalSince(lastUpdateTime) >= updateInterval {
                updateUI()
                lastUpdateTime = now
            }
        }
        
        // Final update to ensure all content is set
        updateUI()
    }
    
    // MARK: - Helper Methods
    
    private func finishResponse() {
        assistant.isReplying = false
        assistant.reasoning = assistant.reasoning?.trimmingCharacters(in: .whitespacesAndNewlines)
 
        // TODO: check this logic
        // Delete response if content is empty and no data files or tools were used
        if assistant.content.isEmpty && assistant.dataFiles.isEmpty && assistant.tools == nil {
            chat.errorDeleteLast()
        }
        
        withAnimation(.easeInOut(duration: 1)) { AppSettings.shared.expandColor = false }
    }
}
