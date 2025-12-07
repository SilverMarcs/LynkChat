//
//  ImageModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

enum ImageModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case zImage
    case gpt
    case nanoBanana
    case nanoBananaPro
    case seedream
    case flux

    static var allCases: [ImageModel] {
        [.zImage, .gpt, .nanoBanana, .nanoBananaPro, .seedream]
    }

    var id: String {
        switch self {
        case .zImage, .flux: "zImage"
        case .gpt: "gpt"
        case .nanoBanana: "nanoBanana"
        case .nanoBananaPro: "nanoBananaPro"
        case .seedream: "seedream"
        }
    }

    var name: String {
        switch self {
        case .zImage, .flux: "Z-Image"
        case .gpt: "GPT"
        case .nanoBanana: "Banana"
        case .nanoBananaPro: "Banana Pro"
        case .seedream: "Seedream"
        }
    }

    var imageName: String {
        switch self {
        case .zImage, .flux: "qwen.symbols"
        case .gpt: "openai.symbols"
        case .nanoBanana, .nanoBananaPro: "gemini.symbols"
        case .seedream: "bytedance.symbols"
        }
    }

    var color: String {
        switch self {
        case .zImage, .flux: "#007BFF"
        case .gpt: "#00947A"
        case .nanoBanana, .nanoBananaPro: "#E64335"
        case .seedream: "#00A8B2"
        }
    }
}
