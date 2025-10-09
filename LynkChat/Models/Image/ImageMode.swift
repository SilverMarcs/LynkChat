//
//  ImageMode.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/10/2025.
//

import Foundation

enum ImageMode: String, Codable, Sendable, CaseIterable {
    case generation
    case editing
    
    var displayName: String {
        switch self {
        case .generation:
            return "Generation"
        case .editing:
            return "Editing"
        }
    }
}
