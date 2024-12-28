//
//  ModelGroup.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import Foundation

enum ModelGroup: String, Identifiable {
    case anthropic
    case openAI
    case google
    case deepseek
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .anthropic: "Anthropic"
        case .openAI: "OpenAI"
        case .google: "Google"
        case .deepseek: "Deepseek"
        }
    }
}
