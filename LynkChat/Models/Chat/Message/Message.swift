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
    
    var model: ChatModel
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
    
    var tools: [ToolCall]?
    
    var inputTokens: Int = 0
    var outputTokens: Int = 0
    var reasoningTokens: Int = 0
    
    private init(role: Role,
                 content: String = "",
                 reasoning: String? = nil,
                 model: ChatModel,
                 dataFiles: [TypedData],
                 tools: [ToolCall]?,
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
        Message(
            role: .user,
            content: content,
            model: .gemini_flash,
            dataFiles: dataFiles,
            tools: nil,
            isReplying: false,
            height: 20
        )
    }
    
    static func assistant(model: ChatModel, content: String = "") -> Message {
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
    func toAPIMessage() -> ChatRequestMessage {
        var contentItems = [MessageContent]()
        
        // For assistant messages with tool calls
        if role == .assistant && tools != nil && !tools!.isEmpty {
            // Add content if present
            if !content.isEmpty {
                contentItems.append(MessageContent(text: content))
            }
            
            // Convert tools to tool calls
            let toolCalls = tools!.map { tool in
                ChatRequestMessage.ToolCallInfo(
                    id: tool.id,
                    type: "function",
                    function: ChatRequestMessage.ToolCallInfo.FunctionInfo(
                        name: tool.tool.rawValue,
                        arguments: tool.arguments
                    )
                )
            }
            
            return ChatRequestMessage(
                role: MessageRole(rawValue: role.rawValue)!,
                content: contentItems,
                toolCalls: toolCalls
            )
        }
        
        // For messages with tool results (convert to tool role messages)
        if let toolList = tools, !toolList.isEmpty, toolList.first?.result != nil {
            // Create separate tool messages for each tool result
            // Note: This returns only the first tool result as a tool message
            // In practice, you may need to handle multiple tool results differently
            if let firstTool = toolList.first, let result = firstTool.result {
                contentItems.append(MessageContent(text: result.text))
                return ChatRequestMessage(
                    role: .tool,
                    content: contentItems,
                    toolCallId: firstTool.id
                )
            }
        }
        
        // Process data files for images
        for dataFile in dataFiles {
            if dataFile.fileType.conforms(to: .image) {
                let imageURL = OpenAIClient.imageDataURL(from: dataFile.data)
                contentItems.append(MessageContent(
                    image: MessageContent.ImageURL(url: imageURL, detail: "auto")
                ))
            }
        }
        
        // Add text content (including reasoning if present)
        var textContent = content
        if let reasoning = reasoning, !reasoning.isEmpty {
            textContent += "\n\nReasoning: \(reasoning)"
        }
        
        if !textContent.isEmpty {
            contentItems.insert(MessageContent(text: textContent), at: 0)
        }
        
        return ChatRequestMessage(
            role: MessageRole(rawValue: role.rawValue)!,
            content: contentItems
        )
    }
}
