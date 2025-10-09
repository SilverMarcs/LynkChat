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
        
        try await processStream()
        
        finishResponse()
    }
    
    // MARK: - Stream Processing
    
    private func processStream() async throws {
        // Create OpenAI client for the assistant's model
        let client = OpenAIClient(
            apiKey: assistant.model.apiKey,
            baseURL: assistant.model.baseURL,
            model: assistant.model.id
        )
        
        // Prepare messages
        let adjustedContext = chat.adjustedContext.dropLast() // removing last assistant msg
        var apiMessages = adjustedContext.map { $0.toAPIMessage() }
        
        // Add system message
        let date = "Today's date is \(Date().formatted(date: .complete, time: .omitted))"
        let systemContent = date + "\n" + chat.config.systemPrompt
        apiMessages.insert(
            ChatRequestMessage(role: .system, content: [MessageContent(text: systemContent)]),
            at: 0
        )
        
        // Local buffers for batching updates
        var contentBuffer = ""
        var reasoningBuffer = assistant.reasoning ?? "" // Placeholder, not used in OpenAI streaming
        
        // Tool call tracking
        var pendingToolCalls: [String: PendingToolCall] = [:]
        
        struct PendingToolCall {
            var id: String
            var name: String
            var argumentsBuffer: String
        }
        
        // Timer for periodic updates
        let updateInterval: TimeInterval = 0.2
        var lastUpdateTime = Date()
        
        // Helper function to update UI
        func updateUI() {
            assistant.content = contentBuffer
            assistant.reasoning = reasoningBuffer.isEmpty ? nil : reasoningBuffer
        }
        
        // Stream the response
        for try await response in client.streamChatCompletion(
            messages: apiMessages,
            temperature: chat.config.temperature.value,
            tools: [] // Tools disabled for now
        ) {
            guard let choice = response.choices.first else { continue }
            let delta = choice.delta
            
            // Handle content
            if let content = delta.content {
                contentBuffer += content
            }
            
            // Handle tool calls
            if let toolCalls = delta.tool_calls {
                for toolCall in toolCalls {
                    let index = toolCall.index ?? 0
                    let key = "\(index)"
                    
                    if let id = toolCall.id, let function = toolCall.function?.name {
                        // Start of a new tool call
                        pendingToolCalls[key] = PendingToolCall(
                            id: id,
                            name: function,
                            argumentsBuffer: toolCall.function?.arguments ?? ""
                        )
                    } else if var pending = pendingToolCalls[key] {
                        // Continue existing tool call
                        if let args = toolCall.function?.arguments {
                            pending.argumentsBuffer += args
                            pendingToolCalls[key] = pending
                        }
                    }
                }
            }
            
            // Handle finish reason
            if let finishReason = choice.finish_reason {
                if finishReason == "tool_calls" {
                    // Finalize tool calls
                    for (_, pending) in pendingToolCalls {
                        if let tool = Tool(rawValue: pending.name) {
                            let toolCall = ToolCall(
                                id: pending.id,
                                tool: tool,
                                arguments: pending.argumentsBuffer,
                                result: nil
                            )
                            if assistant.tools == nil {
                                assistant.tools = []
                            }
                            assistant.tools?.append(toolCall)
                        }
                    }
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
