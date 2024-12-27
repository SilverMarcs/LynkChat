//
//  ChatRequest+ChatResponse.swift
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

struct TokenUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
}

// TODO: beautify this and also use enum
enum ContentItem: Encodable {
    case text(String)
    case image(mimeType: String, data: Data)
    
    private enum CodingKeys: String, CodingKey {
        case type, text, image
    }
    
    private enum ContentType: String, Encodable {
        case text
        case image
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let text):
            try container.encode(ContentType.text, forKey: .type)
            try container.encode(text, forKey: .text)
        case .image(let mimeType, let data):
            try container.encode(ContentType.image, forKey: .type)
            try container.encode(mimeType, forKey: .image) // Optional: Include mimeType if needed
            try container.encode(data.base64EncodedString(), forKey: .image)
        }
    }
}

struct APIMessage: Encodable {
    let role: MessageRole
    let content: [ContentItem]
    
    init(role: MessageRole, content: [ContentItem]) {
        self.role = role
        self.content = content
    }
    
    init(role: MessageRole, text: String) {
        self.role = role
        self.content = [.text(text)]
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

struct APIModel: Codable {
    let id: String
    let name: String?
}
