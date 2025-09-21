//
//  ChatModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation
import UniformTypeIdentifiers

enum ChatModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, Sendable, ModelImageProvider {
    case gemini_2_5_flash
    case gemini_2_5_pro
    case gpt_5
    case gpt_5_mini
    case grok_4
    case grok_4_fast
    case claude_sonnet_4
    case claude_opus_4
    
    var id: String {
        switch self {
        case .gemini_2_5_flash: "gemini-2.5-flash"
        case .gemini_2_5_pro: "gemini-2.5-pro"
        case .gpt_5: "gpt-5"
        case .gpt_5_mini: "gpt-5-mini"
        case .claude_sonnet_4: "claude-sonnet-4"
        case .claude_opus_4: "claude-opus-4"
        case .grok_4: "grok-4"
        case .grok_4_fast: "grok-4-fast"
        }
    }
    
    var name: String {
        switch self {
        case .gemini_2_5_flash: "Gemini 2.5F"
        case .gemini_2_5_pro:"Gemini 2.5P"
        case .gpt_5: "GPT-5"
        case .gpt_5_mini: "GPT-5 Mini"
        case .claude_sonnet_4: "Claude 4S"
        case .claude_opus_4: "Claude 4O"
        case .grok_4: "Grok 4"
        case .grok_4_fast: "Grok 4 Fast"
        }
    }
    
    var imageName: String {
        switch self {
        case .gpt_5, .gpt_5_mini: "openai.symbols"
        case .gemini_2_5_flash, .gemini_2_5_pro: "gemini.symbols"
        case .claude_sonnet_4, .claude_opus_4: "claude.symbols"
        case .grok_4, .grok_4_fast: "xai.symbols"
        }
    }
    
    var color: String {
        switch self {
        case .gpt_5, .gpt_5_mini: "#00947A"
        case .gemini_2_5_flash, .gemini_2_5_pro: "#E64335"
        case .claude_sonnet_4, .claude_opus_4: "#D6683B"
        case .grok_4, .grok_4_fast: "#777777"
        }
    }
    
    var supportedTypes: Set<UTType> {
        switch self {
        case .gemini_2_5_flash, .gemini_2_5_pro:
            [.text, .image, .pdf, .audio, .video]
        case .gpt_5, .gpt_5_mini, .claude_sonnet_4, .claude_opus_4, .grok_4, .grok_4_fast:
            [.text, .image]
        }
    }
}
