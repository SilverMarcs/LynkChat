//
//  ChatRequest+ChatResponse.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import Foundation

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

struct APIMessageContent: Encodable {
    let type: String
    let text: String?
    let image: String?
}

// TODO: beautify this and also use enum
struct APIMessage: Encodable {
    let role: MessageRole
    let content: [APIMessageContent]
    
    init(role: MessageRole, text: String) {
        self.role = role
        self.content = [APIMessageContent(type: "text", text: text, image: nil)]
    }
    
    init(role: MessageRole, imageData: Data) {
        self.role = role
        self.content = [APIMessageContent(type: "image", text: nil, image: imageData.base64EncodedString())]
    }
    
    init(role: MessageRole, text: String, images: [Data]) {
        self.role = role
        var contents = [APIMessageContent(type: "text", text: text, image: nil)]
        contents.append(contentsOf: images.map { APIMessageContent(type: "image", text: nil, image: $0.base64EncodedString()) })
        self.content = contents
    }
    
    init(role: MessageRole, contentItems: [ContentItem]) {
        self.role = role
        self.content = contentItems.map { item in
            switch item {
            case .text(let text):
                return APIMessageContent(type: "text", text: text, image: nil)
            case .image(_, let imageData):
                return APIMessageContent(type: "image", text: nil, image: imageData.base64EncodedString())
            }
        }
    }
}

// TODO: make init that must check whether able to send own api key or not.
struct APIRequest: Encodable {
    let provider: String
    let model: String
    let messages: [APIMessage]
    let stream: Bool
    let customBaseUrl: String?
    let customApiKey: String?
    
    init(provider: String, model: String, messages: [APIMessage], stream: Bool, customBaseUrl: String?, customApiKey: String?) {
        self.provider = provider
        self.model = model
        self.messages = messages
        self.stream = stream
        self.customBaseUrl = customBaseUrl
        
        // TODO: see this
        if AppConfig.shared.sendOwnKey {
            self.customApiKey = customApiKey
        } else {
            self.customApiKey = nil
        }
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
    let name: String
}
