//
//  ChatRequest+ChatResponse.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import Foundation

struct APIModel: Codable {
    let id: String
    let name: String
}

struct APIResponse: Decodable {
    let text: String
    let finishReason: String
    let usage: Usage
    
    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
    }
}

struct APIMessageContent: Encodable {
    let type: String
    let text: String?
    let image: String?
}

struct APIMessage: Encodable {
    let role: String
    let content: [APIMessageContent]
}

struct APIRequest: Encodable {
    let provider: String
    let model: String
    let messages: [APIMessage]
    let stream: Bool
    let customBaseUrl: String?
    let customApiKey: String? // TODO: encrypt this
}

struct UsageResponse: Decodable {
    let finishReason: String
    let usage: Usage
    
    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
    }
}

struct StreamChunk: Decodable {
    let type: String
    let content: String?
    let finishReason: String?
    let usage: Usage?
    
    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
    }
}

struct APIErrorResponse: Decodable {
    let error: ErrorDetails
    
    struct ErrorDetails: Decodable {
        let message: String
        let type: String
        let details: String
    }
}
