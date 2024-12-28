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
    
    var content: String

    @Relationship(deleteRule: .cascade)
    var dataFiles: [TypedData] = []
    var role: MessageRole
    
    @Attribute(.ephemeral)
    var isReplying: Bool = false
    
    var height: CGFloat
    
    @Relationship(deleteRule: .cascade)
    var next: MessageGroup?
    
    // TODO: typed init functions for diff roles
    
    // TOOD: maybe shud pass heigjt
    init(role: MessageRole, content: String = "", model: ChatModel, dataFiles: [TypedData] = [], isReplying: Bool = false, height: CGFloat = 0) {
        self.role = role
        self.content = content
        self.model = model
        self.dataFiles = dataFiles
        self.isReplying = isReplying
        self.height = height
    }

    func copy() -> Message {
        return Message(
            role: role,
            content: content,
            model: model,
            dataFiles: dataFiles,
            isReplying: isReplying,
            height: height
        )
    }
}

extension Message {
    func toAPIMessage() -> APIMessage {
        var contentItems = [ContentItem]()
        
        // Process data files
        let processedDataFiles = FileHelper.processDataFiles2(dataFiles)
        
        // Add processed text content from data files
        let textContents = processedDataFiles.compactMap { item -> String? in
            if case .text(let text) = item {
                return text.isEmpty ? nil : text // Filter out empty strings
            }
            return nil
        }
        
        // Concatenate texts with the original message content
        let combinedText = (textContents + [content])
            .filter { !$0.isEmpty } // Filter out empty strings
            .joined(separator: "\n")
        
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
