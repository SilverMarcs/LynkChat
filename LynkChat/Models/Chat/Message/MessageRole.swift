//
//  MessageRole.swift
//  LynkChat
//
//  Created by Zabir Raihan on 10/07/2024.
//

import Foundation
import OpenAI

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
    case tool
    
    func toOpenAIRole() -> ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .system:
            return .system
        case .tool:
            return .tool
        }
    }
}
