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
    
    var tools: [ChatTool]?
    
    var inputTokens: Int = 0
    var outputTokens: Int = 0
    var reasoningTokens: Int = 0
    
    private init(role: Role,
                 content: String = "",
                 reasoning: String? = nil,
                 model: ChatModel,
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
//    func toAPIMessage() -> APIMessage {
//        var contentItems = [ContentItem]()
//        
//        // Process data files
//        let processedDataFiles = TypedData.processDataFiles(dataFiles)
//        
//        // Create tool usage texts
//        let toolTexts = tools?.map { tool -> String in
//            return """
//                Used \(tool.toolName) tool
//                Arguments: \(tool.args)
//                Tool Result:
//                \(tool.result ?? "No result")
//                """
//        } ?? []
//        
//        // Add the original message content, reasoning (if exists), and tool texts
//        let messageComponents = [content]
//            + (reasoning.map { ["Reasoning: \($0)"] } ?? [])
//            + toolTexts
//        
//        let userText = messageComponents
//            .filter { !$0.isEmpty }
//            .joined(separator: "\n\n")
//        
//        if !userText.isEmpty {
//            contentItems.append(.text(userText))
//        }
//        
//        contentItems.append(contentsOf: processedDataFiles)
//        
//        return APIMessage(role: role, content: contentItems)
//    }
    
    func toChatRequestMessage() -> ChatRequestMessage {
        var messageContents = [MessageContent]()
        
        // Process text content with reasoning and tools
        let toolTexts = tools?.map { tool -> String in
            return """
                Used \(tool.toolName) tool
                Arguments: \(tool.args)
                Tool Result:
                \(tool.result ?? "No result")
                """
        } ?? []
        
        let messageComponents = [content]
            + (reasoning.map { ["Reasoning: \($0)"] } ?? [])
            + toolTexts
        
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
        return ChatRequestMessage(role: messageRole, content: messageContents)
    }
}
