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
        
        // Fetch MCP tools once
        let (openAITools, toolToServer) = await MCPToolAdapter.fetchOpenAITools(enabledServerIds: chat.config.enabledMCPServerIds)
        
        // Prepare base messages (excluding the current assistant message being streamed)
        let adjustedContext = chat.adjustedContext
        let messages = adjustedContext
            .filter { $0.id != assistant.id } // Exclude current assistant message
            .map { $0.toChatRequestMessage() }
        
        // Add system message with date
        let date = "Today's date is \(Date().formatted(date: .complete, time: .omitted))"
        let systemMessage = ChatRequestMessage(
            role: .system,
            content: [MessageContent(text: date + "\n" + chat.config.systemPrompt)]
        )
        let baseMessages = [systemMessage] + messages
        
        // Process initial stream and handle tool calls in a loop
        try await processConversationLoop(baseMessages: baseMessages, openAITools: openAITools, toolToServer: toolToServer)
        
        finishResponse()
    }
    
    // MARK: - Stream Processing with OpenAI Client
    
    private func processConversationLoop(
        baseMessages: [ChatRequestMessage],
        openAITools: [ChatCompletionRequest.Tool],
        toolToServer: [String: MCPServer]
    ) async throws {
        var conversationMessages = baseMessages
        var shouldContinue = true
        
        while shouldContinue {
            let toolCalls = try await streamCompletion(messages: conversationMessages, tools: openAITools)
            
            if !toolCalls.isEmpty {
                // Create assistant message with tool calls
                let assistantToolCallsMessage = createAssistantToolCallsMessage(toolCalls: toolCalls)
                conversationMessages.append(assistantToolCallsMessage)
                
                // Execute tools and get results
                let toolResultMessages = try await executeToolCalls(toolCalls, toolToServer: toolToServer)
                conversationMessages.append(contentsOf: toolResultMessages)
                
                // Continue loop to get assistant's response to tool results
                shouldContinue = true
            } else {
                // No tool calls, we're done
                shouldContinue = false
            }
        }
    }
    
    private func streamCompletion(
        messages: [ChatRequestMessage],
        tools: [ChatCompletionRequest.Tool]
    ) async throws -> [ChatRequestMessage.ToolCallInfo] {
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
            model: model.id
        )
        
        // Stream chat completion
        let stream = client.streamChatCompletion(
            messages: messages,
            temperature: chat.config.temperature.value,
            maxTokens: nil,
            tools: tools.isEmpty ? nil : tools,
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
        
        // Convert accumulated tool calls to ToolCallInfo and save to assistant.tools
        let toolCallInfos: [ChatRequestMessage.ToolCallInfo] = toolCallsAccumulator.values.compactMap { toolCall in
            guard let id = toolCall.id,
                  let name = toolCall.name else {
                return nil
            }
            
            return ChatRequestMessage.ToolCallInfo(
                id: id,
                type: "function",
                function: ChatRequestMessage.ToolCallInfo.FunctionInfo(
                    name: name,
                    arguments: toolCall.arguments ?? "{}"
                )
            )
        }.sorted(by: { $0.id < $1.id }) // Ensure consistent ordering
        
        // Save tool calls to assistant message (without results yet)
        if !toolCallInfos.isEmpty {
            let chatTools = toolCallInfos.map { toolCallInfo in
                ChatTool(
                    toolCallId: toolCallInfo.id,
                    toolName: toolCallInfo.function.name,
                    args: toolCallInfo.function.arguments,
                    result: nil
                )
            }
            assistant.tools = (assistant.tools ?? []) + chatTools
        }
        
        return toolCallInfos
    }
    
    private func createAssistantToolCallsMessage(toolCalls: [ChatRequestMessage.ToolCallInfo]) -> ChatRequestMessage {
        // Assistant message with tool calls should have empty or minimal content
        let content = assistant.content.isEmpty ? " " : assistant.content
        return ChatRequestMessage(
            role: .assistant,
            content: [MessageContent(text: content)],
            toolCalls: toolCalls
        )
    }
    
    private func executeToolCalls(
        _ toolCalls: [ChatRequestMessage.ToolCallInfo],
        toolToServer: [String: MCPServer]
    ) async throws -> [ChatRequestMessage] {
        var toolMessages: [ChatRequestMessage] = []
        
        for toolCall in toolCalls {
            let name = toolCall.function.name
            let toolCallId = toolCall.id
            let argumentsString = toolCall.function.arguments
            
            AppLogger.info("Executing tool: \(name) with args: \(argumentsString)")
            
            var resultText: String
            
            // Parse arguments
            guard let argumentsData = argumentsString.data(using: .utf8),
                  let arguments = try? JSONDecoder().decode([String: AnyCodable].self, from: argumentsData) else {
                AppLogger.error("Invalid arguments for tool \(name): \(argumentsString)")
                resultText = "Error: Invalid arguments"
                
                toolMessages.append(ChatRequestMessage(
                    role: .tool,
                    content: [MessageContent(text: resultText)],
                    toolCallId: toolCallId
                ))
                
                // Update assistant.tools with error result
                updateToolResult(toolCallId: toolCallId, result: resultText)
                continue
            }
            
            // Find server
            guard let server = toolToServer[name] else {
                AppLogger.error("No server found for tool \(name)")
                resultText = "Error: No server configured for this tool"
                
                toolMessages.append(ChatRequestMessage(
                    role: .tool,
                    content: [MessageContent(text: resultText)],
                    toolCallId: toolCallId
                ))
                
                // Update assistant.tools with error result
                updateToolResult(toolCallId: toolCallId, result: resultText)
                continue
            }
            
            do {
                resultText = try await MCPToolAdapter.callToolHTTP(server: server, name: name, arguments: arguments)
                
                AppLogger.info("Tool \(name) result: \(resultText)")
                
                toolMessages.append(ChatRequestMessage(
                    role: .tool,
                    content: [MessageContent(text: resultText)],
                    toolCallId: toolCallId
                ))
                
                // Update assistant.tools with successful result
                updateToolResult(toolCallId: toolCallId, result: resultText)
            } catch {
                AppLogger.error("Error calling tool \(name): \(error.localizedDescription)")
                resultText = "Error: \(error.localizedDescription)"
                
                toolMessages.append(ChatRequestMessage(
                    role: .tool,
                    content: [MessageContent(text: resultText)],
                    toolCallId: toolCallId
                ))
                
                // Update assistant.tools with error result
                updateToolResult(toolCallId: toolCallId, result: resultText)
            }
        }
        
        return toolMessages
    }
    
    private func updateToolResult(toolCallId: String, result: String) {
        guard var tools = assistant.tools,
              let index = tools.firstIndex(where: { $0.toolCallId == toolCallId }) else {
            return
        }
        
        tools[index] = ChatTool(
            toolCallId: tools[index].toolCallId,
            toolName: tools[index].toolName,
            args: tools[index].args,
            result: result
        )
        assistant.tools = tools
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
