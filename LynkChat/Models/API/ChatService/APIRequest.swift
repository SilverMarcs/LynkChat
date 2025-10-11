//
//  APIRequest.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

// TODO: make init that must check whether able to send own api key or not.
struct APIRequest: Encodable {
    let userId: String
    let model: String
    let messages: [APIMessage]
    let temperature: Double
    let thinkingBudget: String
    let system: String?
    let mcpServers: [String: [String: Any]]?
    
    enum CodingKeys: String, CodingKey {
        case userId, model, messages, temperature, thinkingBudget, system, tools, mcpServers
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(model, forKey: .model)
        try container.encode(messages, forKey: .messages)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(thinkingBudget, forKey: .thinkingBudget)
        try container.encodeIfPresent(system, forKey: .system)
        
        if let mcpServers = mcpServers {
            // Encode the dictionary as a nested container
            var mcpContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: .mcpServers)
            for (key, value) in mcpServers {
                try mcpContainer.encode(AnyCodable(value), forKey: DynamicKey(stringValue: key)!)
            }
        }
    }
    
    private struct DynamicKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            return nil
        }
    }
    
    private struct AnyCodable: Encodable {
        let value: Any
        
        init(_ value: Any) {
            self.value = value
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            if let dict = value as? [String: Any] {
                try container.encode(dict.mapValues { AnyCodable($0) })
            } else if let array = value as? [Any] {
                try container.encode(array.map { AnyCodable($0) })
            } else if let string = value as? String {
                try container.encode(string)
            } else if let int = value as? Int {
                try container.encode(int)
            } else if let double = value as? Double {
                try container.encode(double)
            } else if let bool = value as? Bool {
                try container.encode(bool)
            }
        }
    }
}

struct APIMessage: Encodable {
    let role: Message.Role
    let content: [ContentItem]
    
    init(role: Message.Role, content: [ContentItem]) {
        self.role = role
        self.content = content
    }
    
    init(role: Message.Role, text: String) {
        self.role = role
        self.content = [.text(text)]
    }
}

enum ContentItem: Encodable {
    case text(String)
    case file(data: Data, mimeType: String)
    
    private enum CodingKeys: String, CodingKey {
        case type, text, image, data, mimeType, mediaType
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
            
        case .file(let fileData, let mimeType):
            try container.encode("file", forKey: .type)
            // Convert Data to base64 string
            let base64String = fileData.base64EncodedString()
            try container.encode(base64String, forKey: .data)
            try container.encode(mimeType, forKey: .mediaType)
        }
    }
}

struct TitleRequest: Encodable {
    let prompt: String
}
