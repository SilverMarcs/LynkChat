//
//  ModelGroup.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import Foundation

enum ModelGroup: String, CaseIterable, Identifiable {
    case anthropic
    case openAI
    case google
    case deepseek_v3
    case meta
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .anthropic: "Anthropic"
        case .openAI: "OpenAI"
        case .google: "Google"
        case .deepseek_v3: "deepseek_v3"
        case .meta: "Meta"
        }
    }
}
