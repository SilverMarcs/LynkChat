//
//  APIResponse.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import Foundation

// MARK: - Subtypes
struct ToolCall: Decodable {
    let toolCallId: String
    let tool: Tool
    let args: String
}

struct ToolResult: Decodable {
    let toolCallId: String
    let tool: Tool
    let result: String
}

struct TokenUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
}

// MARK: - Streaming Response
enum ResponseType: Decodable {
    case text(content: String)
    case finish(usage: TokenUsage)
    case error(message: String)
    case toolCall(call: ToolCall)
    case toolResult(result: ToolResult)

    enum CodingKeys: String, CodingKey {
        case type
        case content
        case usage
        case toolCallId
        case tool
        case args
        case result
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "text":
            let content = try container.decode(String.self, forKey: .content)
            self = .text(content: content)
            
        case "toolCall":
            let toolCallId = try container.decode(String.self, forKey: .toolCallId)
            let tool = try container.decode(Tool.self, forKey: .tool)
            let args = try container.decode(String.self, forKey: .args)
            self = .toolCall(call: ToolCall(toolCallId: toolCallId, tool: tool, args: args))
            
        case "toolResult":
            let toolCallId = try container.decode(String.self, forKey: .toolCallId)
            let tool = try container.decode(Tool.self, forKey: .tool)
            let result = try container.decode(String.self, forKey: .result)
            self = .toolResult(result: ToolResult(toolCallId: toolCallId, tool: tool, result: result))
            
        case "finish":
            let usage = try container.decode(TokenUsage.self, forKey: .usage)
            self = .finish(usage: usage)
            
        case "error":
            let message = try container.decode(String.self, forKey: .content)
            self = .error(message: message)
            
        default:
            throw RuntimeError("Invalid response Received")
        }
    }
}

// MARK: - Non Streaming Response
struct APIResponse: Decodable {
    let text: String
    let usage: TokenUsage
}

// MARK: - Error Response
struct APIErrorResponse: Decodable {
    let error: ErrorDetails
    
    struct ErrorDetails: Decodable {
        let message: String
        let type: String
        let details: String
    }
}
