//
//  ChatModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation
import UniformTypeIdentifiers

enum ChatModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, Sendable, ModelImageProvider {
    case gemini_flash
    case gemini_pro
    case gpt
    case gpt_mini
    case claude_sonnet
    case claude_opus
    case perplexity
    
    var id: String {
        switch self {
        case .gemini_flash: "gemini-flash"
        case .gemini_pro: "gemini-pro"
        case .gpt: "gpt"
        case .gpt_mini: "gpt-mini"
        case .claude_sonnet: "claude-sonnet"
        case .claude_opus: "claude-opus"
        case .perplexity: "perplexity"
        }
    }
    
    var name: String {
        switch self {
        case .gemini_flash: "Gemini Flash"
        case .gemini_pro: "Gemini Pro"
        case .gpt: "GPT"
        case .gpt_mini: "GPT Mini"
        case .claude_sonnet: "Claude Sonnet"
        case .claude_opus: "Claude Opus"
        case .perplexity: "Perplexity"
        }
    }
    
    var imageName: String {
        switch self {
        case .gpt, .gpt_mini: "openai.symbols"
        case .gemini_flash, .gemini_pro: "gemini.symbols"
        case .claude_sonnet, .claude_opus: "claude.symbols"
        case .perplexity: "perplexity.symbols"
        }
    }
    
    var color: String {
        switch self {
        case .gpt, .gpt_mini: "#00947A"
        case .gemini_flash, .gemini_pro: "#E64335"
        case .claude_sonnet, .claude_opus: "#D6683B"
        case .perplexity: "#47808a"
        }
    }
    
    var supportedTypes: Set<UTType> {
        switch self {
        case .gemini_flash, .gemini_pro:
            [.text, .image, .pdf, .audio, .video]
        case .gpt, .gpt_mini, .claude_sonnet, .claude_opus, .perplexity:
            [.text, .image]
        }
    }
}
