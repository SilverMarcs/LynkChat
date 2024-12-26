//
//  APIRequest.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

// TODO: make init that must check whether able to send own api key or not.
struct APIRequest: Encodable {
    let provider: Provider
    let model: String
    let messages: [APIMessage]
    let system: String?
    let stream: Bool
    
    init(provider: Provider, model: String, messages: [APIMessage], system: String?, stream: Bool) {
        self.provider = provider
        self.model = model
        self.messages = messages
        self.system = system
        self.stream = stream
    }
    
    // Implement custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode provider as provider.type.rawValue
        try container.encode(provider.type.rawValue, forKey: .provider)
        
        // Encode other properties normally
        try container.encode(model, forKey: .model)
        try container.encode(messages, forKey: .messages)
        try container.encode(system, forKey: .system)
        try container.encode(stream, forKey: .stream)
    }
    
    private enum CodingKeys: String, CodingKey {
        case provider
        case model
        case messages
        case system
        case stream
    }
}
