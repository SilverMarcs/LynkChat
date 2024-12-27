//
//  LynkModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

enum LynkModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable {
    case claude3_5sonnet
    case claude3_5haiku
    case gpt4o
    case gpt4omini
    
    var id: String {
        switch self {
        case .claude3_5sonnet: "us.anthropic.claude-3-5-sonnet-20241022-v2:0"
        case .claude3_5haiku: "us.anthropic.claude-3-5-haiku-20241022-v1:0"
        case .gpt4o: "gpt-4o"
        case .gpt4omini: "gpt-4o-mini"
        }
    }
    
    var name: String {
        switch self {
        case .claude3_5sonnet: "Claude-3.5S"
        case .claude3_5haiku: "Claude-3.5H"
        case .gpt4o: "GPT-4o"
        case .gpt4omini: "GPT-4om"
        }
    }
    
    var imageName: String {
        switch self {
            case .claude3_5sonnet, .claude3_5haiku: "anthropic.SFSymbol"
            case .gpt4o, .gpt4omini: "openai.SFSymbol"
        }
    }
    
    var color: String {
        switch self {
        case .claude3_5sonnet, .claude3_5haiku: "#E6784B"
        case .gpt4o, .gpt4omini: "#00947A"
        }
    }
    
    var isEnabled: Bool {
        switch self {
        case .claude3_5sonnet: ModelConfig.shared.enable_claude3_5sonnet
        default: false
        }
    }
}
