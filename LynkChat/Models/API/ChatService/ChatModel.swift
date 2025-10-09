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
    
    var id: String {
        switch self {
        case .gemini_flash: "google/gemini-2.5-flash"
        case .gemini_pro: "google/gemini-2.5-pro"
        case .gpt: "gpt-5"
        case .gpt_mini: "gpt-5-mini"
        case .claude_sonnet: "anthropic/claude-sonnet-4.5"
        case .claude_opus: "claude-opus-4-20250514"
        }
    }
    
    var baseURL: String {
        switch self {
        case .gemini_flash, .gemini_pro:
            return "https://openrouter.ai/api/v1"
        case .gpt, .gpt_mini:
            return "https://ai-gateway.vercel.sh/v1"
        case .claude_sonnet, .claude_opus:
            return "https://openrouter.ai/api/v1"
        }
    }
    
    var apiKey: String {
        let key = apiKeyKey
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    private var apiKeyKey: String {
        switch self {
        case .gemini_flash, .gemini_pro, .claude_opus, .claude_sonnet: "geminiApiKey"
        case .gpt, .gpt_mini: "openaiApiKey"
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
        }
    }
    
    var imageName: String {
        switch self {
        case .gpt, .gpt_mini: "openai.symbols"
        case .gemini_flash, .gemini_pro: "gemini.symbols"
        case .claude_sonnet, .claude_opus: "claude.symbols"
        }
    }
    
    var color: String {
        switch self {
        case .gpt, .gpt_mini: "#00947A"
        case .gemini_flash, .gemini_pro: "#E64335"
        case .claude_sonnet, .claude_opus: "#D6683B"
        }
    }
    
    var supportedTypes: Set<UTType> {
        switch self {
        case .gemini_flash, .gemini_pro:
            [.text, .image, .pdf, .audio, .video]
        case .gpt, .gpt_mini, .claude_sonnet, .claude_opus:
            [.text, .image]
        }
    }
}
