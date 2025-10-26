//
//  GenerationMode.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/10/2025.
//

import SwiftUI

enum GenerationMode: String, Identifiable, Codable, CaseIterable {
    case create = "Create"
    case edit = "Edit"
//    case video = "Video"
    
    var id: String { rawValue }
    
    var imageName: String {
        switch self {
        case .create: "sparkles.2"
        case .edit: "wand.and.sparkles"
//        case .video: "video.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .create: .accent
        case .edit: .blue
//        case .video: .orange
        }
    }
}
