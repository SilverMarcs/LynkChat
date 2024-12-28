//
//  APIResponse.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import Foundation

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

struct APIResponse: Decodable {
    let text: String
    let usage: TokenUsage
}

enum ResponseType {
    case text(content: String)
    case finish(usage: TokenUsage)
    case error(message: String)
}

struct StreamChunk {
    let type: ResponseType
    let finishReason: String?
}

extension StreamChunk: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case content
        case finishReason
        case usage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let content = try? container.decode(String.self, forKey: .content) {
            self.type = .text(content: content)
        } else if let usage = try? container.decode(TokenUsage.self, forKey: .usage) {
            self.type = .finish(usage: usage)
        } else if let message = try? container.decode(String.self, forKey: .content) {
            self.type = .error(message: message)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid response type")
        }
        
        self.finishReason = try? container.decode(String.self, forKey: .finishReason)
    }
}
