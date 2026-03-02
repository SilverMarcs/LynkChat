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
    case klingImageO3 = "kling_image_o3"
    case grokImagine = "grok_imagine"
    case gptImage15 = "gpt_image_1_5"
    case nanoBanana2 = "nano_banana_2"

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

    var imageName: String {
        switch self {
        case .seedreamV50Lite, .seedreamV45: "bytedance.symbols"
        case .klingImageO3: "kling.symbols"
        case .grokImagine, .gptImage15: "openai.symbols"
        case .nanoBanana2: "gemini.symbols"
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

    var apiPath: String {
        switch self {
        case .seedreamV50Lite:
            "/api/v3/bytedance/seedream-v5.0-lite"
        case .seedreamV45:
            "/api/v3/bytedance/seedream-v4.5"
        case .klingImageO3:
            "/api/v3/kwaivgi/kling-image-o3/text-to-image"
        case .grokImagine:
            "/api/v3/x-ai/grok-imagine-image/text-to-image"
        case .gptImage15:
            "/api/v3/openai/gpt-image-1.5/text-to-image"
        case .nanoBanana2:
            "/api/v3/google/nano-banana-2/text-to-image"
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
        case .klingImageO3:
            return [
                "prompt": prompt,
                "aspect_ratio": "9:16",
                "resolution": "1k",
                "num_images": 1,
                "output_format": "png"
            ]
        case .grokImagine:
            return [
                "prompt": prompt,
                "aspect_ratio": "9:16",
                "output_format": "jpeg"
            ]
        case .gptImage15:
            return [
                "prompt": prompt,
                "size": "1024*1536",
                "quality": "medium",
                "output_format": "jpeg",
                "enable_sync_mode": false,
                "enable_base64_output": false
            ]
        case .nanoBanana2:
            return [
                "prompt": prompt,
                "aspect_ratio": "9:16",
                "resolution": "1k",
                "output_format": "png",
                "enable_sync_mode": false,
                "enable_base64_output": false
            ]
        }
    }
}
