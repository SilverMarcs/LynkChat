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
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .anthropic: "Anthropic"
        case .openAI: "OpenAI"
        }
    }
}
