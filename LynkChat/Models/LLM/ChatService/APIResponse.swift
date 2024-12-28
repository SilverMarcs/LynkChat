//
//  APIResponse.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import Foundation

// TODO: see how to split into multiple files
struct APIResponse: Decodable {
    let text: String
    let usage: TokenUsage
}

enum StreamResponse {
    case text(String)
    case usage(TokenUsage)
}

struct StreamChunk: Decodable {
    let type: String
    let content: String?
    let finishReason: String?
    let usage: TokenUsage?
}

struct TokenUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
}

struct APIErrorResponse: Decodable {
    let error: ErrorDetails
    
    struct ErrorDetails: Decodable {
        let message: String
        let type: String
        let details: String
    }
}
