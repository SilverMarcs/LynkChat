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

struct TitleRequest: Encodable {
    let prompt: String
}

enum HTTPMethod: String {
    case POST
    case GET
}

enum APIPath {
    case chat
    case title
    case image
    case upload
    
    var pathString: String {
        switch self {
        case .chat:
            return "/chat"
        case .title:
            return "/chat/title"
        case .image:
            return "/image"
        case .upload:
            return "/upload"
        }
    }
}
