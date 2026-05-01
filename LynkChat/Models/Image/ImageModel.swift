//
//  ImageModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

enum ImageModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case seedreamV50Lite = "seedream_v5_0_lite"
    case seedreamV45 = "seedream_v4_5"
    case grokImagine = "grok_imagine"
    case gptImage2 = "gpt_image_2"
    case nanoBananaPro = "nano_banana_pro"
    case wan27 = "wan_2_7"

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

    var imageName: String {
        switch self {
        case .seedreamV50Lite, .seedreamV45: "bytedance.symbols"
        case .grokImagine, .gptImage2: "openai.symbols"
        case .nanoBananaPro: "gemini.symbols"
        case .wan27: "qwen.symbols"
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

    var apiPath: String {
        switch self {
        case .seedreamV50Lite:
            "/api/v3/bytedance/seedream-v5.0-lite"
        case .seedreamV45:
            "/api/v3/bytedance/seedream-v4.5"
        case .grokImagine:
            "/api/v3/x-ai/grok-imagine-image/text-to-image"
        case .gptImage2:
            "/api/v3/openai/gpt-image-2/text-to-image"
        case .nanoBananaPro:
            "/api/v3/google/nano-banana-pro/text-to-image"
        case .wan27:
            "/api/v3/alibaba/wan-2.7/text-to-image"
        }
    }

    func requestBody(prompt: String) -> [String: Any] {
        switch self {
        case .seedreamV50Lite:
            return [
                "prompt": prompt,
                "size": "1440*2560",
                "enable_sync_mode": false,
                "enable_base64_output": false
            ]
        case .seedreamV45:
            return [
                "prompt": prompt,
                "size": "1440*2560",
                "enable_sync_mode": false,
                "enable_base64_output": false
            ]
        case .grokImagine:
            return [
                "prompt": prompt,
                "aspect_ratio": "9:16",
                "output_format": "jpeg"
            ]
        case .gptImage2:
            return [
                "prompt": prompt,
                "aspect_ratio": "9:16",
                "resolution": "1k",
                "quality": "medium",
                "enable_sync_mode": false,
                "enable_base64_output": false
            ]
        case .nanoBananaPro:
            return [
                "prompt": prompt,
                "aspect_ratio": "9:16",
                "resolution": "1k",
                "output_format": "png",
                "enable_sync_mode": false,
                "enable_base64_output": false
            ]
        case .wan27:
            return [
                "prompt": prompt,
                "size": "1440*2560",
                "thinking_mode": false,
                "seed": -1
            ]
        }
    }
}
