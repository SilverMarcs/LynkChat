//
//  ChatModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation
import UniformTypeIdentifiers

enum ChatModel: String, Identifiable, Hashable, Codable, Equatable, ModelImageProvider {
    case small_model
    case large_model
    case gpt_4o
    case reasoning_model
    
    static var allCases: [ChatModel] {
        AppConfig.shared.showDebugMenu ?
        [
            .small_model,
            .large_model,
            .gpt_4o,
            .reasoning_model,
        ] :
        [
            .small_model,
//            .large_model,
            .reasoning_model,
//            .gpt_4o
        ]
    }
    
    var id: String {
        switch self {
        case .small_model: "small-model"
        case .large_model: "large-model"
        case .reasoning_model: "reasoning-model"
        case .gpt_4o: "gpt-4o"
        }
    }
    
    var name: String {
        switch self {
        case .small_model: "Standard"
        case .large_model: "Advanced"
        case .reasoning_model: "Reasoning"
        case .gpt_4o: "Versatile"
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
            case .small_model: "gemini.symbols"
            case .large_model: "claude.symbols"
            case .reasoning_model: "deepseek.symbols"
            case .gpt_4o: "openai.symbols"
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
        case .small_model: "#E64335"
        case .large_model: "#D6683B"
        case .reasoning_model: "#4F65E9"
        case .gpt_4o: "#00947A"
        }
    }
    
    var supportsTool: Bool {
        switch self {
        case .small_model, .large_model, .gpt_4o:
            true
        case .reasoning_model:
            true
        }
    }
    
    var supportedTypes: Set<UTType> {
        switch self {
        case .small_model, .reasoning_model:
            [.text, .pdf, .audio, .image]
        case .large_model, .gpt_4o:
            [.text, .image]
//        case .reasoning_model:
//            [.text]
        }
    }
    
    var description: String {
        switch self {
        case .small_model:
            "Very fast model while maintaining high quality. Uses Gemini-2 Flash"
        case .large_model:
            "Advanced model for difficult tasks like coding. Uses Claude-3.7 Sonnet"
        case .reasoning_model:
            "Model that thinks before responding. Uses DeepSeek R1"
        case .gpt_4o:
            "OpenAI's leading multimodal model. Uses GPT-4o"
        }
    }
    
    var price: TokenUsage {
        switch self {
        case .small_model: .init(promptTokens: 1, completionTokens: 3)
        case .large_model: .init(promptTokens: 3, completionTokens: 8)
        case .reasoning_model: .init(promptTokens: 2, completionTokens: 4)
        case .gpt_4o: .init(promptTokens: 3, completionTokens: 6)
        }
    }
}

struct TokenUsage: Codable {
    var promptTokens: Int
    var completionTokens: Int
}
