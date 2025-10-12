//
//  ImageEditingModel.swift
//  LynkChat
//
//  Created by GitHub Copilot on 11/10/2025.
//

import Foundation

enum ImageEditingModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case seedream
    case nanoBanana
    case qwen

    var id: String { rawValue }

    var name: String {
        switch self {
        case .seedream: "Seedream"
        case .nanoBanana: "Banana"
        case .qwen: "Qwen"
        }
    }
    
    var apiPath: String {
        switch self {
        case .seedream: "/api/v3/bytedance/seedream-v4/edit"
        case .nanoBanana: "/api/v3/google/nano-banana/edit"
        case .qwen: "/api/v3/wavespeed-ai/qwen-image/edit-plus"
        }
    }
    
    var color: String {
        switch self {
        case .nanoBanana: "#E64335"
        case .seedream: "#6431e2"
        case .qwen: "#007BFF"
        }
    }
    
    var imageName: String {
        "storm.SFSymbol"
    }
}
