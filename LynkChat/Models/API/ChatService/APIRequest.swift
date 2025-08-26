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
    let tools: [String]
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
    case image(image: Data, mimeType: String)
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
            
        case .image(let imageData, let mimeType):
            try container.encode("image", forKey: .type)
            // Convert Data to base64 string
            let base64String = imageData.base64EncodedString()
            try container.encode(base64String, forKey: .image)
            try container.encodeIfPresent(mimeType, forKey: .mediaType)
            
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
