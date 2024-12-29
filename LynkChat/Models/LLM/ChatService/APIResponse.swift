//
//  APIResponse.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import Foundation

// MARK: - Subtypes
struct ToolResponse: Codable {
    let toolName: Plugin
    let args: String
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
    case tool(tool: ToolResponse)

    enum CodingKeys: String, CodingKey {
        case type
        case content
        case usage
        case toolName
        case args
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "text":
            let content = try container.decode(String.self, forKey: .content)
            self = .text(content: content)
        case "tool":
            let tool = try container.decode(ToolResponse.self, forKey: .toolName)
            self = .tool(tool: ToolResponse(toolName: tool.toolName, args: tool.args))
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
