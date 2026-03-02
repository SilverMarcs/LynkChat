//
//  ImageEditingModel.swift
//  LynkChat
//
//  Created by GitHub Copilot on 11/10/2025.
//

import Foundation

enum ImageEditingModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case seedreamV50Lite = "seedream_v5_0_lite_edit"
    case seedreamV45 = "seedream_v4_5_edit"
    case klingImageO3 = "kling_image_o3_edit"
    case grokImagine = "grok_imagine_edit"
    case gptImage15 = "gpt_image_1_5_edit"
    case nanoBanana2 = "nano_banana_2_edit"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .seedreamV50Lite: "Seedream V5 Lite"
        case .seedreamV45: "Seedream V4.5"
        case .klingImageO3: "Kling Image O3"
        case .grokImagine: "Grok Imagine"
        case .gptImage15: "GPT Image 1.5"
        case .nanoBanana2: "Nano Banana 2"
        }
    }
    
    var apiPath: String {
        switch self {
        case .seedreamV50Lite: "/api/v3/bytedance/seedream-v5.0-lite/edit"
        case .seedreamV45: "/api/v3/bytedance/seedream-v4.5/edit"
        case .klingImageO3: "/api/v3/kwaivgi/kling-image-o3/edit"
        case .grokImagine: "/api/v3/x-ai/grok-imagine-image/edit"
        case .gptImage15: "/api/v3/openai/gpt-image-1.5/edit"
        case .nanoBanana2: "/api/v3/google/nano-banana-2/edit"
        }
    }
    
    var color: String {
        switch self {
        case .seedreamV50Lite, .seedreamV45: "#00A8B2"
        case .klingImageO3: "#70EECD"
        case .grokImagine: "#111111"
        case .gptImage15: "#00947A"
        case .nanoBanana2: "#E64335"
        }
    }
    
    var imageName: String {
        switch self {
        case .seedreamV50Lite, .seedreamV45: "bytedance.symbols"
        case .klingImageO3: "kling.symbols"
        case .grokImagine: "xai.symbols"
        case .gptImage15: "openai.symbols"
        case .nanoBanana2: "gemini.symbols"
        }
    }
}
