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

struct ReasoningResponse: Decodable {
    let type: String
    let reasoning: String
}

struct ReasoningEndResponse: Decodable {
    let type: String
    let stub: String
}

struct FinishResponse: Decodable {
    let type: String
    let inputTokens: Int
    let outputTokens: Int
    let reasoningTokens: Int
}

struct ErrorResponse: Decodable {
    let type: String
    let content: String
}

struct FileResponse: Decodable {
    let type: String
    let base64: String
    let mimeType: String 
}

struct ToolCallResponse: Decodable {
    let type: String
    let toolCallId: String
    let toolName: String
    let args: String
}

struct ToolResultResponse: Decodable {
    let type: String
    let toolCallId: String
    let result: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        toolCallId = try container.decode(String.self, forKey: .toolCallId)
        
        // Decode result as JSON string
        let anyValue = try container.decode(AnyDecodable.self, forKey: .result)
        let jsonData = try JSONSerialization.data(withJSONObject: anyValue.value, options: [])
        result = String(data: jsonData, encoding: .utf8) ?? "{}"
    }
    
    private enum CodingKeys: String, CodingKey {
        case type, toolCallId, result
    }
}

// MARK: - Streaming Response
enum ResponseType: Decodable {
    case text(TextResponse)
    case reasoning(ReasoningResponse)
    case reasoningEnd(ReasoningEndResponse)
    case finish(FinishResponse)
    case error(ErrorResponse)
    case file(FileResponse)
    case toolCall(ToolCallResponse)
    case toolResult(ToolResultResponse)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let textResponse = try? container.decode(TextResponse.self) {
            self = .text(textResponse)
        } else if let reasoningResponse = try? container.decode(ReasoningResponse.self) {
            self = .reasoning(reasoningResponse)
        } else if let reasoningEndResponse = try? container.decode(ReasoningEndResponse.self) {
            self = .reasoningEnd(reasoningEndResponse)
        } else if let finishResponse = try? container.decode(FinishResponse.self) {
            self = .finish(finishResponse)
        } else if let errorResponse = try? container.decode(ErrorResponse.self) {
            self = .error(errorResponse)
        } else if let fileResponse = try? container.decode(FileResponse.self) {
            self = .file(fileResponse)
        } else if let toolCallResponse = try? container.decode(ToolCallResponse.self) {
            self = .toolCall(toolCallResponse)
        } else if let toolResultResponse = try? container.decode(ToolResultResponse.self) {
            self = .toolResult(toolResultResponse)
        } else {
            throw RuntimeError("Invalid response received \(container)")
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
    let error: String
}

// MARK: - File Upload Response
struct FileUploadResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - Title Response
struct TitleResponse: Codable {
    let title: String
}

// MARK: - RAG List Response
struct RAGResource: Codable {
    let id: Int
    let filename: String
    let mimeType: String
    let createdAt: String
    let updatedAt: String
}

struct RAGListResponse: Codable {
    let success: Bool
    let data: [RAGResource]
    let count: Int
}

// MARK: - RAG Delete Response
struct RAGDeleteResponse: Codable {
    let success: Bool
    let message: String
}
