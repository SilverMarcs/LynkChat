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
    case nanoBananaPro
    case fluxPro
    case qwen

    var id: String { rawValue }

    var name: String {
        switch self {
        case .seedream: "Seedream"
        case .nanoBanana: "Banana"
        case .nanoBananaPro: "Banana Pro"
        case .fluxPro: "FLUX.2"
        case .qwen: "Qwen"
        }
    }
    
    var apiPath: String {
        switch self {
        case .seedream: "/api/v3/bytedance/seedream-v4.5/edit"
        case .nanoBanana: "/api/v3/google/nano-banana/edit"
        case .nanoBananaPro: "/api/v3/google/nano-banana-pro/edit"
        case .fluxPro: "/api/v3/wavespeed-ai/flux-2-pro/edit"
        case .qwen: "/api/v3/wavespeed-ai/qwen-image/edit-plus"
        }
    }
    
    var color: String {
         switch self {
         case .nanoBanana, .nanoBananaPro: "#E64335"
         case .seedream: "#00A8B2"
         case .fluxPro: "#6431e2"
         case .qwen: "#007BFF"
         }
     }
     
     var imageName: String {
         switch self {
         case .nanoBanana, .nanoBananaPro: "gemini.symbols"
         case .seedream: "bytedance.symbols"
         case .fluxPro: "flux.symbols"
         case .qwen: "qwen.symbols"
         }
     }
}
