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

    @Relationship(deleteRule: .cascade)
    var dataFiles: [TypedData]
    
    @Attribute(.ephemeral)
    var isReplying: Bool = false
    
    var height: CGFloat = 20
    
    @Relationship(deleteRule: .cascade)
    var next: MessageGroup?
    
    var tools: [ChatTool]?
    
    private init(role: Role,
                 content: String = "",
                 model: ChatModel,
                 dataFiles: [TypedData],
                 tools: [ChatTool]?,
                 isReplying: Bool = false) {
        self.role = role
        self.content = content
        self.model = model
        self.dataFiles = dataFiles
        self.tools = tools
        self.isReplying = isReplying
    }

    func copy() -> Message {
        return Message(
            role: role,
            content: content,
            model: model,
            dataFiles: dataFiles,
            tools: tools,
            isReplying: isReplying
        )
    }
    
    static func user(content: String, dataFiles: [TypedData] = []) -> Message {
        Message(
            role: .user,
            content: content,
            model: ModelConfig.shared.defaultModel,
            dataFiles: dataFiles,
            tools: nil,
            isReplying: false
        )
    }
    
    static func assistant(model: ChatModel, content: String = "") -> Message {
        Message(
            role: .assistant,
            content: content,
            model: model,
            dataFiles: [],
            tools: [],
            isReplying: true
        )
    }

    enum Role: String, Codable {
        case user
        case assistant
    }
}

// TODO: pass tool call and results
extension Message {
    func toAPIMessage() async -> APIMessage {
        var contentItems = [ContentItem]()
        
        // Process data files
        let processedDataFiles = await TypedData.processDataFiles(dataFiles)
        
        // Add processed text content from data files
        let textContents = processedDataFiles.compactMap { item -> String? in
            if case .text(let text) = item {
                return text.isEmpty ? nil : text // Filter out empty strings
            }
            return nil
        }
        
        // Create tool usage texts
        let toolTexts = tools?.map { tool -> String in
            let resultText: String
            if tool.tool == .imageGeneration {
                resultText = "generated image was shown to user"
            } else {
                resultText = tool.result ?? "No result"
            }
            
            return """
                Used \(tool.tool.rawValue) tool
                Arguments: \(tool.args)
                Tool Result:
                \(resultText)
                """
        } ?? []
        
        // Concatenate texts with the original message content and tool texts
        let combinedText = (textContents + [content] + toolTexts)
            .filter { !$0.isEmpty } // Filter out empty strings
            .joined(separator: "\n\n") // Added double newline for better separation
        
        // Only add text content if it's not empty
        if !combinedText.isEmpty {
            contentItems.append(.text(combinedText))
        }
        
        // Add images from data files
        let imageItems = processedDataFiles.compactMap { item -> (mimeType: String, data: Data)? in
            if case .image(let mimeType, let data) = item {
                return (mimeType: mimeType, data: data)
            }
            return nil
        }
        
        // Add image items to contentItems
        imageItems.forEach { imageItem in
            contentItems.append(.image(mimeType: imageItem.mimeType, data: imageItem.data))
        }
        
        return APIMessage(role: role, content: contentItems)
    }
}
