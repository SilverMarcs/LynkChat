//
//  ChatModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

enum ChatModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case claude3_5sonnet
    case claude3_5haiku
    case gpt4o
    case gpt4omini
    case gemini2Flash
    case deepseek
    
    var id: String {
        switch self {
        case .claude3_5sonnet: "claude-3-5-sonnet"
        case .claude3_5haiku: "claude-3-5-haiku"
        case .gpt4o: "gpt-4o"
        case .gpt4omini: "gpt-4o-mini"
        case .gemini2Flash: "gemini-2-flash"
        case .deepseek: "deepseek-chat"
        }
    }
    
    var name: String {
        switch self {
        case .claude3_5sonnet: "Claude-3.5S"
        case .claude3_5haiku: "Claude-3.5H"
        case .gpt4o: "GPT-4o"
        case .gpt4omini: "GPT-4om"
        case .gemini2Flash: "Gemini-2F"
        case .deepseek: "DeepSeek"
        }
    }

    var imageName: String {
        switch self {
            case .claude3_5sonnet, .claude3_5haiku: "claude.symbols"
            case .gpt4o, .gpt4omini: "openai.symbols"
            case .gemini2Flash: "gemini.symbols"
            case .deepseek: "deepseek.symbols"
        }
    }

    var color: String {
        switch self {
        case .claude3_5sonnet, .claude3_5haiku: "#E6784B"
        case .gpt4o, .gpt4omini: "#00947A"
        case .gemini2Flash: "#E64335"
        case .deepseek: "#4F65E9"
        }
    }

    var group: ModelGroup {
        switch self {
        case .claude3_5sonnet, .claude3_5haiku:
            return .anthropic
        case .gpt4o, .gpt4omini:
            return .openAI
        case .gemini2Flash:
            return .google
        case .deepseek:
            return .deepseek
        }
    }
    
//    var supportsImage: Bool {
//    var supportsPlugin: Bool {
//    var costPerMillionTokens: Double {
    
    static func groupedModels() -> [ModelGroup: [ChatModel]] {
        Dictionary(grouping: ChatModel.allCases) { $0.group }
    }
    
    static func groupedEnabledModels() -> [ModelGroup: [ChatModel]] {
        Dictionary(
            grouping: ChatModel.allCases.filter { ModelConfig.shared.isEnabled($0) }
        ) { $0.group }
    }
}

