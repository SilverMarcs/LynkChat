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
            baseURL: model.provider.baseURL,
            model: model.modelString
        )
        
        let (openAITools, toolToServer) = await MCPToolAdapter.fetchOpenAITools(enabledServerIds: chat.config.enabledMCPServerIds)
        
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
        var reasoningBuffer = assistant.reasoning ?? ""
        var toolCallsAccumulator: [Int: (id: String?, name: String?, arguments: String?)] = [:]
        
        let updateInterval: TimeInterval = 0.2
        var lastUpdateTime = Date()
        
        let originalContent = isFollowUp ? assistant.content : ""
        
        func updateUI() {
            // jsut do assistant.content = originalContent + contentBuffer. followupcheck not needed

            if isFollowUp {
                assistant.content = originalContent + "\n" + contentBuffer
            } else {
                assistant.content = contentBuffer
            }
            assistant.reasoning = reasoningBuffer.isEmpty ? nil : reasoningBuffer
        }
        
        // Prepare messages
        let messages = if isFollowUp {
            chat.adjustedContext.flatMap { $0.toChatRequestMessage() }
        } else {
            chat.adjustedContext.dropLast().flatMap { $0.toChatRequestMessage() }
        }
        let allMessages = buildMessagesWithSystem(messages)
        let label = isFollowUp ? "Follow-up Request" : "Initial Request"
        
        printMessageStructure(allMessages, label: label)
        
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
            
            if let content = choice.delta.content {
                contentBuffer += content
            }
            
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
            
            let now = Date()
            if now.timeIntervalSince(lastUpdateTime) >= updateInterval {
                updateUI()
                lastUpdateTime = now
            }
        }
        
        updateUI()
        
        // Handle tool calls if any
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
        assistant.reasoning = assistant.reasoning?.trimmingCharacters(in: .whitespacesAndNewlines)
 
        if assistant.content.isEmpty && assistant.dataFiles.isEmpty && assistant.tools == nil {
            chat.errorDeleteLast()
        }
        
        withAnimation(.easeInOut(duration: 1)) { AppSettings.shared.expandColor = false }
    }
    
    private func printMessageStructure(_ messages: [ChatRequestMessage], label: String) {
        print("\n=== \(label) (Count: \(messages.count)) ===")
        for (index, message) in messages.enumerated() {
            print("\n[\(index)] role: \(message.role.rawValue)")
            
            if let toolCallId = message.tool_call_id {
                print("    tool_call_id: \(toolCallId)")
            }
            
            print("    content items: \(message.content.count)")
            for (contentIndex, content) in message.content.enumerated() {
                print("      [\(contentIndex)] type: \(content.type.rawValue)")
                if let text = content.text {
                    let preview = String(text.prefix(10))
                    print("          text: \"\(preview)...\" (length: \(text.count))")
                }
                if let imageUrl = content.image_url {
                    print("          image_url: \(String(imageUrl.url.prefix(30)))...")
                }
            }
            
            if let toolCalls = message.tool_calls {
                print("    tool_calls: \(toolCalls.count)")
                for (toolIndex, toolCall) in toolCalls.enumerated() {
                    print("      [\(toolIndex)] id: \(toolCall.id)")
                    print("          function.name: \(toolCall.function.name)")
                    let argsPreview = String(toolCall.function.arguments.prefix(5))
                    print("          function.arguments: \"\(argsPreview)...\" (length: \(toolCall.function.arguments.count))")
                }
            }
        }
        print("\n=================================\n")
    }
}
