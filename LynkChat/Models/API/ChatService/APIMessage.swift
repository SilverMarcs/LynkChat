//
//  APIMessage.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import Foundation

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
        case type, text, image, data, mimeType
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .image(let image, let mimeType):
            try container.encode("image", forKey: .type)
            try container.encode(image, forKey: .image)
            try container.encodeIfPresent(mimeType, forKey: .mimeType)
        case .file(let data, let mimeType):
            try container.encode("file", forKey: .type)
            try container.encode(data, forKey: .data)
            try container.encode(mimeType, forKey: .mimeType)
        }
    }
}
