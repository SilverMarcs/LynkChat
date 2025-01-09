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
    let sessionId: String
    let model: String
    let messages: [APIMessage]
    let temperature: Double
    let maxTokens: Int
    let system: String?
    let stream: Bool
    let tools: [String]
}

enum HTTPMethod: String {
    case POST
    case GET
}

enum APIPath {
    case chat
    case title
    case image
    
    var pathString: String {
        switch self {
        case .chat:
            return "/chat"
        case .title:
            return "/title"
        case .image:
            return "/image"
        }
    }
}
