//
//  ChatModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation
import UniformTypeIdentifiers

enum ChatModel: String, Identifiable, Hashable, Codable, Equatable, ModelImageProvider {
    case gpt_4_1
    case o4_mini
    case gemini_2_5_flash
    case claude_sonnet_4
    case claude_opus_4
    
    static var allCases: [ChatModel] {
        [
            .gemini_2_5_flash,
            .gpt_4_1,
            .o4_mini,
            .claude_sonnet_4,
            .claude_opus_4,
        ]
    }
    
    var id: String {
        switch self {
        case .gpt_4_1: "gpt-4.1"
        case .o4_mini: "o4-mini"
        case .gemini_2_5_flash: "gemini-2.5-flash"
        case .claude_sonnet_4: "claude-sonnet-4"
        case .claude_opus_4: "claude-opus-4"
        }
    }
    
    var name: String {
        switch self {
        case .gpt_4_1: "GPT-4.1"
        case .o4_mini: "o4-Mini"
        case .gemini_2_5_flash: "Gemini-2.5F"
        case .claude_sonnet_4: "Claude-4S"
        case .claude_opus_4: "Claude-4O"
        }
    }
    
    var imageName: String {
        switch self {
        case .gpt_4_1, .o4_mini: "openai.symbols"
        case .gemini_2_5_flash: "gemini.symbols"
        case .claude_sonnet_4, .claude_opus_4: "claude.symbols"
        }
    }
    
    var color: String {
        switch self {
        case .gpt_4_1: "#00947A"
        case .o4_mini: "#00947A"
        case .gemini_2_5_flash: "#E64335"
        case .claude_sonnet_4: "#D6683B"
        case .claude_opus_4: "#D6683B"
        }
    }
    
    var supportsTool: Bool {
        true
    }
    
    var supportedTypes: Set<UTType> {
        switch self {
        case .gemini_2_5_flash:
            [.text, .image, .pdf, .audio, .video]
        case .gpt_4_1, .o4_mini, .claude_sonnet_4, .claude_opus_4:
            [.text, .image]
        }
    }
    
    var description: String {
        switch self {
        case .gpt_4_1:
            "OpenAI GPT-4.1: Latest generation, versatile and powerful."
        case .o4_mini:
            "OpenAI O4 Mini: Lightweight, fast, and efficient."
        case .gemini_2_5_flash:
            "Google Gemini 2.5 Flash: Fast and high quality."
        case .claude_sonnet_4:
            "Anthropic Claude Sonnet 4: Advanced for coding and reasoning."
        case .claude_opus_4:
            "Anthropic Claude Opus 4: Most capable Claude model."
        }
    }
    
    var price: TokenUsage {
        switch self {
        case .gpt_4_1: .init(promptTokens: 3, completionTokens: 6)
        case .o4_mini: .init(promptTokens: 2, completionTokens: 4)
        case .gemini_2_5_flash: .init(promptTokens: 1, completionTokens: 3)
        case .claude_sonnet_4: .init(promptTokens: 3, completionTokens: 8)
        case .claude_opus_4: .init(promptTokens: 4, completionTokens: 10)
        }
    }
}

struct TokenUsage: Codable {
    var promptTokens: Int
    var completionTokens: Int
}
