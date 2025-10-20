//
//  GenerationMode.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/10/2025.
//

import SwiftUI

enum GenerationMode: String, Identifiable, Codable, CaseIterable, Sendable {
    case generation = "Generation"
    case editing = "Editing"
    case video = "Video"
    
    var id: String { rawValue }
    
    var imageName: String {
        switch self {
        case .generation: "sparkles.2"
        case .editing: "wand.and.sparkles"
        case .video: "video.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .generation: .accent
        case .editing: .blue
        case .video: .orange
        }
    }
}
