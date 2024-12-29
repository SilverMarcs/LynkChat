//
//  APIResponse.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import Foundation


// MARK: - Response Models
struct TextResponse: Decodable {
    let type: String
    let content: String
}

struct FinishResponse: Decodable {
    let type: String
    let promptTokens: Int
    let completionTokens: Int
}

struct ErrorResponse: Decodable {
    let type: String
    let content: String
}

struct ToolCallResponse: Decodable {
    let type: String
    let toolCallId: String
    let tool: Tool
    let args: String
}

struct ToolResultResponse: Decodable {
    let type: String
    let toolCallId: String
    let tool: Tool
    let result: String
}

// MARK: - Streaming Response
enum ResponseType: Decodable {
    case text(TextResponse)
    case finish(FinishResponse)
    case error(ErrorResponse)
    case toolCall(ToolCallResponse)
    case toolResult(ToolResultResponse)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let textResponse = try? container.decode(TextResponse.self) {
            self = .text(textResponse)
        } else if let finishResponse = try? container.decode(FinishResponse.self) {
            self = .finish(finishResponse)
        } else if let errorResponse = try? container.decode(ErrorResponse.self) {
            self = .error(errorResponse)
        } else if let toolCallResponse = try? container.decode(ToolCallResponse.self) {
            self = .toolCall(toolCallResponse)
        } else if let toolResultResponse = try? container.decode(ToolResultResponse.self) {
            self = .toolResult(toolResultResponse)
        } else {
            throw RuntimeError("Invalid response received \(container)") // TODO: test this line
        }
    }
}

// MARK: - Non Streaming Response
struct APIResponse: Decodable {
    let text: String
    let promptTokens: Int
    let completionTokens: Int
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
