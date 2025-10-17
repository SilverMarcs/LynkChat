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
        
        // Tool calls accumulator: index -> (id, name, arguments)
        var toolCallsAccumulator: [Int: (id: String?, name: String?, arguments: String?)] = [:]
        
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
            model: model.modelString
        )
        
        // Prepare messages
        let adjustedContext = chat.adjustedContext.dropLast() // removing last user msg
        // Filter out assistant messages with empty content (these are local messages being updated)
        let messages = adjustedContext
            .filter { !($0.role == .assistant && $0.content.isEmpty) }
            .flatMap { $0.toChatRequestMessage() }
        
        // Add system message with date
        let date = "Today's date is \(Date().formatted(date: .complete, time: .omitted))"
        let systemMessage = ChatRequestMessage(
            role: .system,
            content: [MessageContent(text: date + "\n" + chat.config.systemPrompt)]
        )
        let allMessages = [systemMessage] + messages
        
        // Fetch MCP tools (HTTP only for now) and pass to OpenAI as functions
        let (openAITools, toolToServer) = await MCPToolAdapter.fetchOpenAITools(enabledServerIds: chat.config.enabledMCPServerIds)

        // Stream chat completion
        let stream = client.streamChatCompletion(
            messages: allMessages,
            temperature: chat.config.temperature.value,
            maxTokens: nil,
            tools: openAITools.isEmpty ? nil : openAITools,
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
            
            if let usage = response.usage {
                user.inputTokens = usage.prompt_tokens ?? 0
                assistant.outputTokens = usage.completion_tokens ?? 0
                assistant.reasoningTokens = usage.completion_tokens_details?.reasoning_tokens ?? 0
            }
            
            // Handle tool calls
            if let toolCalls = choice.delta.tool_calls {
                for toolCall in toolCalls {
                    let index = toolCall.index ?? 0
                    
                    // Initialize if new
                    if toolCallsAccumulator[index] == nil {
                        toolCallsAccumulator[index] = (id: nil, name: nil, arguments: nil)
                    }
                    
                    // Accumulate fields
                    if let id = toolCall.id {
                        toolCallsAccumulator[index]!.id = id
                    }
                    if let name = toolCall.function?.name {
                        toolCallsAccumulator[index]!.name = (toolCallsAccumulator[index]!.name ?? "") + name
                    }
                    if let args = toolCall.function?.arguments {
                        toolCallsAccumulator[index]!.arguments = (toolCallsAccumulator[index]!.arguments ?? "") + args
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
        
        // Execute tool calls if any
        if !toolCallsAccumulator.isEmpty {
            // Convert accumulated tool calls to ChatTool objects and store in assistant
            let chatTools = toolCallsAccumulator.values.compactMap { toolCall -> ChatTool? in
                guard let id = toolCall.id, let name = toolCall.name else { return nil }
                return ChatTool(
                    toolCallId: id,
                    toolName: name,
                    args: toolCall.arguments ?? "{}"
                )
            }
            assistant.tools = chatTools
            
            // Execute tools and update results
            try await executeToolCalls(toolToServer: toolToServer)
            
            // Trigger follow-up request for assistant to respond based on tool results
            try await getToolResponseFromAssistant()
        }
    }
    
    private func executeToolCalls(toolToServer: [String: MCPServer]) async throws {
        guard let tools = assistant.tools else { return }
        
        // Execute each tool and update its result
        for (index, tool) in tools.enumerated() {
            // Parse arguments
            guard let argumentsData = tool.args.data(using: .utf8),
                  let arguments = try? JSONDecoder().decode([String: AnyCodable].self, from: argumentsData) else {
                assistant.tools?[index].result = "Error: Invalid arguments"
                continue
            }
            
            // Find server
            guard let server = toolToServer[tool.toolName] else {
                assistant.tools?[index].result = "Error: No server configured for this tool"
                continue
            }
            
            do {
                let resultJSON = try await MCPToolAdapter.callToolHTTP(
                    server: server,
                    name: tool.toolName,
                    arguments: arguments
                )
                assistant.tools?[index].result = resultJSON
            } catch {
                assistant.tools?[index].result = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func getToolResponseFromAssistant() async throws {
        assistant.isReplying = true
        
        var contentBuffer = ""
        var reasoningBuffer = assistant.reasoning ?? ""
        
        func updateUI() {
            assistant.content = contentBuffer
            assistant.reasoning = reasoningBuffer.isEmpty ? nil : reasoningBuffer
        }
        
        let model = chat.config.model
        let client = OpenAIClient(
            apiKey: model.apiKey,
            baseURL: model.baseURL,
            model: model.modelString
        )
        
        // Prepare messages including the assistant's tool calls and results
        let adjustedContext = chat.adjustedContext.dropLast() // removing last user msg
        let messages = adjustedContext
            .filter { !($0.role == .assistant && $0.content.isEmpty && $0.tools == nil) }
            .flatMap { $0.toChatRequestMessage() }
        
        let date = "Today's date is \(Date().formatted(date: .complete, time: .omitted))"
        let systemMessage = ChatRequestMessage(
            role: .system,
            content: [MessageContent(text: date + "\n" + chat.config.systemPrompt)]
        )
        let allMessages = [systemMessage] + messages
        
        // Stream the follow-up response (no tools this time)
        let stream = client.streamChatCompletion(
            messages: allMessages,
            temperature: chat.config.temperature.value,
            maxTokens: nil,
            tools: nil,
            thinkingBudget: chat.config.thinkingBudget
        )
        
        let updateInterval: TimeInterval = 0.2
        var lastUpdateTime = Date()
        
        for try await response in stream {
            guard let choice = response.choices.first else { continue }
            
            if let content = choice.delta.content {
                contentBuffer += content
            }
            
            if let reasoning = choice.delta.reasoning {
                reasoningBuffer += reasoning
            }
            
            if let usage = response.usage {
                if let completionTokens = usage.completion_tokens {
                    assistant.outputTokens = completionTokens
                }
                if let reasoningTokens = usage.completion_tokens_details?.reasoning_tokens {
                    assistant.reasoningTokens = reasoningTokens
                }
            }
            
            let now = Date()
            if now.timeIntervalSince(lastUpdateTime) >= updateInterval {
                updateUI()
                lastUpdateTime = now
            }
        }
        
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
