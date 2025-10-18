//
//  MessageTypes.swift
//  SwiftAI
//
//  Created on 05/10/2025.
//

import Foundation

// MARK: - Message Types

enum MessageRole: String, Codable {
    case system
    case user
    case assistant
    case tool
}

enum MessageContentType: String, Codable {
    case text
    case imageUrl = "image_url"
}

struct MessageContent: Codable {
    var type: MessageContentType
    var text: String?
    var image_url: ImageURL?
    
    struct ImageURL: Codable {
        let url: String
        let detail: String?
    }
    
    init(text: String) {
        self.type = .text
        self.text = text
        self.image_url = nil
    }
    
    init(image: ImageURL) {
        self.type = .imageUrl
        self.text = nil
        self.image_url = image
    }
}

struct ChatRequestMessage: Codable {
     let role: MessageRole
     let content: [MessageContent]
     let tool_calls: [ToolCallInfo]?
     let tool_call_id: String?
     let reasoning_details: [ReasoningDetail]?
     
     struct ToolCallInfo: Codable {
         let id: String
         let type: String
         let function: FunctionInfo
         
         struct FunctionInfo: Codable {
             let name: String
             let arguments: String
         }
     }
     
     init(role: MessageRole, content: [MessageContent], toolCalls: [ToolCallInfo]? = nil, toolCallId: String? = nil, reasoningDetails: [ReasoningDetail]? = nil) {
         self.role = role
         self.content = content
         self.tool_calls = toolCalls
         self.tool_call_id = toolCallId
         self.reasoning_details = reasoningDetails
     }
}
