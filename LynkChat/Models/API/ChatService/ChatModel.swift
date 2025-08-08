//
//  ChatModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation
import UniformTypeIdentifiers

enum ChatModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case gpt_5
    case gpt_5_mini
    case gpt_5_nano
    case gemini_2_5_flash
    case claude_sonnet_4
    case claude_opus_4
    
    var id: String {
        switch self {
        case .gpt_5: "gpt-5"
        case .gpt_5_mini: "gpt-5-mini"
        case .gpt_5_nano: "gpt-5-nano"
        case .gemini_2_5_flash: "gemini-2.5-flash"
        case .claude_sonnet_4: "claude-sonnet-4"
        case .claude_opus_4: "claude-opus-4"
        }
    }
    
    var name: String {
        switch self {
        case .gpt_5: "GPT-5"
        case .gpt_5_mini: "GPT-5 Mini"
        case .gpt_5_nano: "GPT-5 Nano"
        case .gemini_2_5_flash: "Gemini 2.5 Flash"
        case .claude_sonnet_4: "Claude 4 Sonnet"
        case .claude_opus_4: "Claude 4 Opus"
        }
    }
    
    var imageName: String {
        switch self {
        case .gpt_5, .gpt_5_mini, .gpt_5_nano: "openai.symbols"
        case .gemini_2_5_flash: "gemini.symbols"
        case .claude_sonnet_4, .claude_opus_4: "claude.symbols"
        }
    }
    
    var color: String {
        switch self {
        case .gpt_5, .gpt_5_mini, .gpt_5_nano: "#00947A"
        case .gemini_2_5_flash: "#E64335"
        case .claude_sonnet_4, .claude_opus_4: "#D6683B"
        }
    }
    
    var supportsTool: Bool {
        true
    }
    
    var supportedTypes: Set<UTType> {
        switch self {
        case .gemini_2_5_flash:
            [.text, .image, .pdf, .audio, .video]
        case .gpt_5, .gpt_5_mini, .gpt_5_nano, .claude_sonnet_4, .claude_opus_4:
            [.text, .image]
        }
    }
}

struct TokenUsage: Codable {
    var promptTokens: Int
    var completionTokens: Int
}
