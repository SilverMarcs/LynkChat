//
//  RequestResponseTypes.swift
//  SwiftAI
//
//  Created on 05/10/2025.
//

import Foundation

// MARK: - Request/Response Types

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatRequestMessage]
    let stream: Bool
    let temperature: Double?
    let max_tokens: Int?
    let tools: [Tool]?
    let reasoning: Reasoning?
    
    struct Tool: Codable {
        let type: String
        let function: Function
        
        struct Function: Codable {
            let name: String
            let description: String?
            let parameters: [String: AnyCodable]?
        }
    }
}

struct Reasoning: Codable {
    let effort: ThinkingBudget
}

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}

struct ChatStreamResponse: Codable {
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let choices: [StreamChoice]
    let usage: Usage?
    
    struct StreamChoice: Codable {
        let index: Int
        let delta: Delta
        let finish_reason: String?
    }
    
    struct Delta: Codable {
        let role: String?
        let content: String?
        let reasoning: String?
        let tool_calls: [ToolCall]?
    }
    
    struct ToolCall: Codable {
        let index: Int?
        let id: String?
        let type: String?
        let function: FunctionCall?
        
        struct FunctionCall: Codable {
            let name: String?
            let arguments: String?
        }
    }
    
    struct Usage: Codable {
        let prompt_tokens: Int?
        let completion_tokens: Int?
        let total_tokens: Int?
        let completion_tokens_details: CompletionTokensDetails?
        
        struct CompletionTokensDetails: Codable {
            let reasoning_tokens: Int?
        }
    }
}
