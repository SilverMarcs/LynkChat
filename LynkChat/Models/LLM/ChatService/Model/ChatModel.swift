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
    case claude3_5haiku
    case gpt4o
    case gpt4omini
    case gemini2Flash
    case deepseek_v3
    case deepseek_r1
    case llama3_70
    
    static var allCases: [ChatModel] {
        [.claude3_5haiku, .claude3_7sonnet, .gpt4omini, .gpt4o, .gemini2Flash, .deepseek_v3, .deepseek_r1, .llama3_70]
    }
    
    var id: String {
        switch self {
        case .claude3_7sonnet: "claude-3-7-sonnet"
        case .claude3_5haiku: "claude-3-5-haiku"
        case .gpt4o: "gpt-4o"
        case .gpt4omini: "gpt-4o-mini"
        case .gemini2Flash: "gemini-2-flash"
        case .deepseek_v3: "deepseek-chat"
        case .deepseek_r1: "deepseek-reasoning"
        case .llama3_70: "llama-3-70"
        }
    }
    
    var name: String {
        switch self {
        case .claude3_7sonnet: "Claude-3.7S"
        case .claude3_5haiku: "Claude-3.5H"
        case .gpt4o: "GPT-4o"
        case .gpt4omini: "GPT-4om"
        case .gemini2Flash: "Gemini-2F"
        case .deepseek_v3: "DeepSeek-V3"
        case .deepseek_r1: "DeepSeek-R1"
        case .llama3_70: "Llama-3-70B"
        }
    }

    var imageName: String {
        switch self {
            case .claude3_7sonnet, .claude3_5haiku: "claude.symbols"
            case .gpt4o, .gpt4omini: "openai.symbols"
            case .gemini2Flash: "gemini.symbols"
            case .deepseek_v3: "deepseek.symbols"
            case .deepseek_r1: "deepseek.symbols"
            case .llama3_70: "meta.symbols"
        }
    }

    var color: String {
        switch self {
        case .claude3_7sonnet, .claude3_5haiku: "#E6784B"
        case .gpt4o, .gpt4omini: "#00947A"
        case .gemini2Flash: "#E64335"
        case .deepseek_v3: "#4F65E9"
        case .deepseek_r1: "#4F65E9"
        case .llama3_70: "#2B66D9"
        }
    }

    var group: ModelGroup {
        switch self {
        case .claude3_7sonnet, .claude3_5haiku:
            return .anthropic
        case .gpt4o, .gpt4omini:
            return .openAI
        case .gemini2Flash:
            return .google
        case .deepseek_v3, .deepseek_r1:
            return .deepseek_v3
        case .llama3_70:
            return .meta
        }
    }
    
    var supportsTool: Bool {
        switch self {
        case .claude3_7sonnet, .claude3_5haiku, .gpt4o, .gpt4omini, .deepseek_v3, .gemini2Flash:
            true
        default:
            false
        }
    }
    
    var supportedTypes: Set<UTType> {
        switch self {
        case .claude3_7sonnet, .gpt4o, .gpt4omini, .gemini2Flash:
            [.text, .pdf, .audio, .image]
        case .deepseek_v3, .deepseek_r1, .claude3_5haiku, .llama3_70:
            [.text, .pdf, .audio]
        }
    }
    
    var price: TokenUsage {
        switch self {
        case .claude3_5haiku: .init(promptTokens: 1, completionTokens: 3)
        case .claude3_7sonnet: .init(promptTokens: 4, completionTokens: 10)
        case .gpt4o: .init(promptTokens: 3, completionTokens: 8)
        case .gpt4omini: .init(promptTokens: 1, completionTokens: 3)
        case .gemini2Flash: .init(promptTokens: 1, completionTokens: 3)
        case .deepseek_v3: .init(promptTokens: 2, completionTokens: 4)
        case .deepseek_r1: .init(promptTokens: 2, completionTokens: 4)
        case .llama3_70: .init(promptTokens: 2, completionTokens: 4)
        }
    }
    
    static func groupedModels() -> [ModelGroup: [ChatModel]] {
        Dictionary(grouping: ChatModel.allCases) { $0.group }
    }
    
    static func groupedEnabledModels() -> [ModelGroup: [ChatModel]] {
        Dictionary(
            grouping: ChatModel.allCases.filter { ModelConfig.shared.isEnabled($0) }
        ) { $0.group }
    }
}

struct TokenUsage: Codable {
    var promptTokens: Int
    var completionTokens: Int
}
