//
//  ChatResponse.swift
//  LynkChat
//
//  Created by Zabir Raihan on 14/09/2024.
//

import Foundation

enum StreamResponse {
    case content(String)
    case totalTokens(TokenUsage)
}

struct TokenUsage {
    let inputTokens: Int
    let outputTokens: Int
}

struct NonStreamResponse {
    let content: String?
    let inputTokens: Int
    let outputTokens: Int
}
