//
//  Message.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/06/2024.
//

import Foundation
import SwiftData

@Model
final class Message: Equatable, Identifiable, Hashable {
    var id: UUID = UUID()
    var date: Date = Date()
    
    var model: ModelInfo
    var role: Role
    var content: String
    var reasoning: String?

    @Relationship(deleteRule: .cascade)
    var dataFiles: [TypedData]
    
    @Attribute(.ephemeral)
    var isReplying: Bool = false
    
    var height: CGFloat
    
    @Relationship(deleteRule: .cascade)
    var next: MessageGroup?
    
    var tools: [ChatTool]?
    
    var inputTokens: Int = 0
    var outputTokens: Int = 0
    var reasoningTokens: Int = 0
    
    private init(role: Role,
                 content: String = "",
                 reasoning: String? = nil,
                 model: ModelInfo,
                 dataFiles: [TypedData],
                 tools: [ChatTool]?,
                 isReplying: Bool = false,
                 height: CGFloat,
                 inputTokens: Int = 0,
                 outputTokens: Int = 0,
                 reasoningTokens: Int = 0) {
        self.role = role
        self.content = content
        self.reasoning = reasoning
        self.model = model
        self.dataFiles = dataFiles
        self.tools = tools
        self.isReplying = isReplying
        self.height = height
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.reasoningTokens = reasoningTokens
    }

    func copy() -> Message {
        return Message(
            role: role,
            content: content,
            reasoning: reasoning,
            model: model,
            dataFiles: dataFiles,
            tools: tools,
            isReplying: isReplying,
            height: height,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            reasoningTokens: reasoningTokens
        )
    }
    
    static func user(content: String, dataFiles: [TypedData] = []) -> Message {
        return Message(
            role: .user,
            content: content,
            model: ModelInfo(providerId: UUID(), modelString: "", displayName: ""),
            dataFiles: dataFiles,
            tools: nil,
            isReplying: false,
            height: 20
        )
    }
    
    static func assistant(model: ModelInfo, content: String = "") -> Message {
        Message(
            role: .assistant,
            content: content,
            model: model,
            dataFiles: [],
            tools: [],
            isReplying: true,
            height: 0
        )
    }

    enum Role: String, Codable {
        case user
        case assistant
    }
}

extension Message {
    func toChatRequestMessage() -> [ChatRequestMessage] {
        var messageContents = [MessageContent]()
        
        // Process text content with reasoning (but NOT tools - they're handled separately)
        let messageComponents = [content]
            + (reasoning.map { ["Reasoning: \($0)"] } ?? [])
        
        let userText = messageComponents
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
        
        if !userText.isEmpty {
            messageContents.append(MessageContent(text: userText))
        }
        
        // Process data files
        for dataFile in dataFiles {
            if dataFile.fileType.conforms(to: .text) {
                messageContents.append(MessageContent(text: dataFile.formattedTextContent))
            } else if dataFile.fileType.conforms(to: .image) {
                let dataURL = OpenAIClient.imageDataURL(from: dataFile.data, mimeType: dataFile.mimeType)
                let imageURL = MessageContent.ImageURL(url: dataURL, detail: nil)
                messageContents.append(MessageContent(image: imageURL))
            }
            // Other file types (PDF, audio, video) are not yet supported by OpenAI API
        }
        
        // Ensure we always have at least one content item (API requirement)
        if messageContents.isEmpty {
            messageContents.append(MessageContent(text: " "))
        }
        
        let messageRole: MessageRole = role == .user ? .user : .assistant
        var messages: [ChatRequestMessage] = []
        
        // For assistant messages with tool calls, create assistant message with tool_calls
        if role == .assistant, let tools = tools, !tools.isEmpty {
            let toolCalls = tools.map { tool in
                ChatRequestMessage.ToolCallInfo(
                    id: tool.toolCallId,
                    type: "function",
                    function: ChatRequestMessage.ToolCallInfo.FunctionInfo(
                        name: tool.toolName,
                        arguments: tool.args
                    )
                )
            }
            
            // Assistant message with tool calls
            messages.append(ChatRequestMessage(
                role: .assistant,
                content: messageContents,
                toolCalls: toolCalls
            ))
            
            // Tool result messages (only if results exist)
            for tool in tools where tool.result != nil {
                messages.append(ChatRequestMessage(
                    role: .tool,
                    content: [MessageContent(text: String(tool.result!.prefix(20000)))],
                    toolCallId: tool.toolCallId
                ))
//                if tool.result!.count >= 20000 {
//                    print("tool result", tool.result)
//                }
            }
        } else {
            // Regular message without tools
            messages.append(ChatRequestMessage(role: messageRole, content: messageContents))
        }
        
        return messages
    }
}
