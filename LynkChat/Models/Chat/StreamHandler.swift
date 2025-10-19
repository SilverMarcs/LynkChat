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
        let model = chat.config.model
        let client = OpenAIClient(
            apiKey: model.provider.apiKey,
            baseURL: model.provider.baseURL
        )
        
        let (openAITools, toolToServer) = await MCPToolAdapter.fetchOpenAITools(
            enabledServerIds: chat.config.enabledMCPServerIds
        )
        
        try await streamLoop(
            client: client,
            openAITools: openAITools,
            toolToServer: toolToServer,
            isFollowUp: false
        )
    }
    
    private func streamLoop(
        client: OpenAIClient,
        openAITools: [ChatCompletionRequest.Tool],
        toolToServer: [String: MCPServer],
        isFollowUp: Bool
    ) async throws {
        var contentBuffer = ""
        var toolCallsAccumulator: [Int: (id: String?, name: String?, arguments: String?)] = [:]
        
        let updateInterval: TimeInterval = 0.2
        var lastUpdateTime = Date()
        
        let originalContent = isFollowUp ? assistant.content : ""
        
        func updateUI() {
            if isFollowUp {
                assistant.content = originalContent + "\n" + contentBuffer
            } else {
                assistant.content = contentBuffer
            }
        }
        
        let messages = if isFollowUp {
            chat.adjustedContext.flatMap { $0.toChatRequestMessage() }
        } else {
            chat.adjustedContext.dropLast().flatMap { $0.toChatRequestMessage() }
        }
        
        let allMessages = buildMessagesWithSystem(messages)
        
        let stream = client.streamChatCompletion(
            messages: allMessages,
            model: chat.config.model.modelString,
            temperature: chat.config.temperature.value,
            maxTokens: nil,
            tools: openAITools.isEmpty ? nil : openAITools,
            thinkingBudget: chat.config.thinkingBudget
        )
        
        for try await response in stream {
            guard let choice = response.choices.first else { continue }
            
            // Handle content streaming
            if let content = choice.delta.content {
                contentBuffer += content
            }
            
            // Handle reasoning details
            if let reasoningDetails = choice.delta.reasoning_details {
                if assistant.reasoningDetails == nil {
                    assistant.reasoningDetails = []
                }
                for detail in reasoningDetails {
                    let key = detail.index ?? 0
                    if key < assistant.reasoningDetails?.count ?? 0 {
                        assistant.reasoningDetails?[key] = mergeReasoningDetails(
                            assistant.reasoningDetails![key],
                            detail
                        )
                    } else {
                        assistant.reasoningDetails?.append(detail)
                    }
                }
            }
            
            // Handle token usage
            if let usage = response.usage {
                user.inputTokens = usage.prompt_tokens ?? 0
                assistant.outputTokens = usage.completion_tokens ?? 0
                assistant.reasoningTokens = usage.completion_tokens_details?.reasoning_tokens ?? 0
            }
            
            // Handle annotations
            if let annotations = choice.message?.annotations {
                assistant.fileAnnotations = annotations
            }
            
            // Handle tool calls
            if let toolCalls = choice.delta.tool_calls {
                for toolCall in toolCalls {
                    let index = toolCall.index ?? 0
                    
                    if toolCallsAccumulator[index] == nil {
                        toolCallsAccumulator[index] = (id: nil, name: nil, arguments: nil)
                    }
                    
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
            
            // Update UI at throttled interval
            let now = Date()
            if now.timeIntervalSince(lastUpdateTime) >= updateInterval {
                updateUI()
                lastUpdateTime = now
            }
        }
        
        updateUI()
        
        // Handle tool execution and follow-up
        if !toolCallsAccumulator.isEmpty {
            let newChatTools = toolCallsAccumulator.values.compactMap { toolCall -> ChatTool? in
                guard let id = toolCall.id, let name = toolCall.name else { return nil }
                return ChatTool(
                    toolCallId: id,
                    toolName: name,
                    args: toolCall.arguments ?? "{}"
                )
            }
            
            assistant.tools?.append(contentsOf: newChatTools)
            
            try await executeToolCalls(toolToServer: toolToServer)
            
            try await streamLoop(
                client: client,
                openAITools: openAITools,
                toolToServer: toolToServer,
                isFollowUp: true
            )
        }
    }
    
    private func executeToolCalls(toolToServer: [String: MCPServer]) async throws {
        guard let tools = assistant.tools else { return }
        
        for (index, tool) in tools.enumerated() {
            if tool.result != nil {
                continue
            }
            
            guard let argumentsData = tool.args.data(using: .utf8),
                  let arguments = try? JSONDecoder().decode([String: AnyCodable].self, from: argumentsData) else {
                assistant.tools?[index].result = "Error: Invalid arguments"
                continue
            }
            
            guard let server = toolToServer[tool.toolName] else {
                assistant.tools?[index].result = "Error: No server configured for this tool"
                continue
            }
            
            let resultJSON = try await MCPToolAdapter.callToolHTTP(
                server: server,
                name: tool.toolName,
                arguments: arguments
            )
            
            assistant.tools?[index].result = resultJSON
        }
    }
    
    private func mergeReasoningDetails(
        _ existing: ReasoningDetail,
        _ new: ReasoningDetail
    ) -> ReasoningDetail {
        var merged = existing
        if let newText = new.text, !newText.isEmpty {
            merged.text = (merged.text ?? "") + newText
        }
        if let newSummary = new.summary, !newSummary.isEmpty {
            merged.summary = (merged.summary ?? "") + newSummary
        }
        if let newData = new.data, !newData.isEmpty {
            merged.data = (merged.data ?? "") + newData
        }
        return merged
    }
    
    // MARK: - Helper Methods
    
    private func buildMessagesWithSystem(_ messages: [ChatRequestMessage]) -> [ChatRequestMessage] {
        let date = "Today's date is \(Date().formatted(date: .complete, time: .omitted))"
        let systemMessage = ChatRequestMessage(
            role: .system,
            content: [MessageContent(text: date + "\n" + chat.config.systemPrompt)]
        )
        return [systemMessage] + messages
    }
    
    private func finishResponse() {
        assistant.isReplying = false
        
        if assistant.content.isEmpty && assistant.dataFiles.isEmpty && assistant.tools == nil {
            chat.errorDeleteLast()
        }
        
        withAnimation(.easeInOut(duration: 1)) {
            AppSettings.shared.expandColor = false
        }
    }
}
