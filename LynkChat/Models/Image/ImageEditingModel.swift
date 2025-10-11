//
//  ImageEditingModel.swift
//  LynkChat
//
//  Created by GitHub Copilot on 11/10/2025.
//

import Foundation

enum ImageEditingModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case seedream = "bytedance/seedream-v4/edit"
    case nanoBanana = "google/nano-banana/edit"
    case gpt = "openai/gpt-image-1"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .seedream: "Seedream"
        case .nanoBanana: "Nano Banana"
        case .gpt: "GPT Image 1"
        }
    }
    
    var apiPath: String {
        switch self {
        case .seedream: "/api/v3/bytedance/seedream-v4/edit"
        case .nanoBanana: "/api/v3/google/nano-banana/edit"
        case .gpt: "/api/v3/openai/gpt-image-1"
        }
    }
    
    var color: String {
        switch self {
        case .gpt: "#00947A"
        case .nanoBanana: "#E64335"
        case .seedream: "#6431e2"
        }
    }
    
    var imageName: String {
        "flux.symbols"
    }
}
