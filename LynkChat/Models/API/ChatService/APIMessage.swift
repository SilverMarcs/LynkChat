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
    case image(mimeType: String, data: Data)
    case file(mimeType: String, data: Data, fileName: String)
    
    private enum CodingKeys: String, CodingKey {
        case type, text, image, file, mimeType, fileName
    }
    
    private enum ContentType: String, Encodable {
        case text
        case image
        case file
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let text):
            try container.encode(ContentType.text, forKey: .type)
            try container.encode(text, forKey: .text)
        case .image(let mimeType, let data):
            try container.encode(ContentType.image, forKey: .type)
            try container.encode(data, forKey: .image)
            try container.encode(mimeType, forKey: .mimeType)
        case .file(let mimeType, let data, let fileName):
            try container.encode(ContentType.file, forKey: .type)
            try container.encode(data, forKey: .file)
            try container.encode(mimeType, forKey: .mimeType)
            try container.encode(fileName, forKey: .fileName)
        }
    }
}
