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
    case grokImagine = "grok_imagine_edit"
    case gptImage2 = "gpt_image_2_edit"
    case nanoBananaPro = "nano_banana_pro_edit"
    case wan27 = "wan_2_7_edit"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .seedreamV50Lite: "Seedream V5 Lite"
        case .seedreamV45: "Seedream V4.5"
        case .grokImagine: "Grok Imagine"
        case .gptImage2: "GPT Image 2"
        case .nanoBananaPro: "Nano Banana Pro"
        case .wan27: "Wan 2.7"
        }
    }

    var apiPath: String {
        switch self {
        case .seedreamV50Lite: "/api/v3/bytedance/seedream-v5.0-lite/edit"
        case .seedreamV45: "/api/v3/bytedance/seedream-v4.5/edit"
        case .grokImagine: "/api/v3/x-ai/grok-imagine-image/edit"
        case .gptImage2: "/api/v3/openai/gpt-image-2/edit"
        case .nanoBananaPro: "/api/v3/google/nano-banana-pro/edit"
        case .wan27: "/api/v3/alibaba/wan-2.7/image-edit"
        }
    }

    var color: String {
        switch self {
        case .seedreamV50Lite, .seedreamV45: "#00A8B2"
        case .grokImagine: "#111111"
        case .gptImage2: "#00947A"
        case .nanoBananaPro: "#E64335"
        case .wan27: "#615CED"
        }
    }

    var imageName: String {
        switch self {
        case .seedreamV50Lite, .seedreamV45: "bytedance.symbols"
        case .grokImagine: "xai.symbols"
        case .gptImage2: "openai.symbols"
        case .nanoBananaPro: "gemini.symbols"
        case .wan27: "qwen.symbols"
        }
    }
}
