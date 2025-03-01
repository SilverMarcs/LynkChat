//
//  ChatModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation
import UniformTypeIdentifiers

enum ChatModel: String, Identifiable, Hashable, Codable, Equatable, ModelImageProvider {
    case claude3_7sonnet
    case small_model
    case large_model
    case reasoning_model
    
    static var allCases: [ChatModel] {
        AppConfig.shared.showDebugMenu ?
        [
//            .claude3_7sonnet,
            .small_model,
            .large_model,
            .reasoning_model
        ] :
        [
            .small_model,
            .large_model,
            .reasoning_model
        ]
    }
    
    var id: String {
        switch self {
        case .claude3_7sonnet: "claude-3-7-sonnet"
        case .small_model: "small-model"
        case .large_model: "large-model"
        case .reasoning_model: "reasoning-model"
        }
    }
    
    var name: String {
        switch self {
        case .claude3_7sonnet: "Claude-3.7S"
        case .small_model: "Standard"
        case .large_model: "Advanced"
        case .reasoning_model: "Reasoning"
        }
    }

    
//    case .claude3_7sonnet, .claude3_5haiku: "claude.symbols"
//    case .gpt4o, .gpt4omini: "openai.symbols"
//    case .gemini2Flash: "gemini.symbols"
//    case .deepseek_v3: "deepseek.symbols"
//    case .deepseek_r1: "deepseek.symbols"
//    case .llama3_70: "meta.symbols"
    
    var imageName: String {
        switch self {
            case .claude3_7sonnet: "claude.symbols"
            case .small_model: "gemini.symbols"
            case .large_model: "claude.symbols"
            case .reasoning_model: "deepseek.symbols"
        }
    }

//    case .claude3_7sonnet, .claude3_5haiku: "#E6784B"
//    case .gpt4o, .gpt4omini: "#00947A"
//    case .gemini2Flash: "#E64335"
//    case .deepseek_v3: "#4F65E9"
//    case .deepseek_r1: "#4F65E9"
//    case .llama3_70: "#2B66D9"
    
    var color: String {
        switch self {
        case .claude3_7sonnet: "#D6683B"
        case .small_model: "#E64335"
        case .large_model: "#D6683B"
        case .reasoning_model: "#4F65E9"
        }
    }
    
    var supportsTool: Bool {
        switch self {
        case .claude3_7sonnet, .small_model, .large_model:
            true
        case .reasoning_model:
            false
        }
    }
    
    var supportedTypes: Set<UTType> {
        switch self {
        case .claude3_7sonnet, .small_model, .large_model:
            [.text, .pdf, .audio, .image]
        case .reasoning_model:
            [.text, .pdf, .audio]
        }
    }
    
    var price: TokenUsage {
        switch self {
        case .claude3_7sonnet: .init(promptTokens: 4, completionTokens: 10)
        case .small_model: .init(promptTokens: 1, completionTokens: 3)
        case .large_model: .init(promptTokens: 3, completionTokens: 8)
        case .reasoning_model: .init(promptTokens: 2, completionTokens: 4)
        }
    }
}

struct TokenUsage: Codable {
    var promptTokens: Int
    var completionTokens: Int
}
