//
//  ImageModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

enum ImageModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case gpt
    case nanoBanana
    case seedream

    var id: String {
        switch self {
        case .gpt: "gpt"
        case .nanoBanana: "nanoBanana"
        case .seedream: "seedream"
        }
    }

    var name: String {
        switch self {
        case .gpt: "GPT"
        case .nanoBanana: "Banana"
        case .seedream: "Seedream"
        }
    }

    var imageName: String {
        switch self {
        case .gpt: "openai.symbols"
        case .nanoBanana: "gemini.symbols"
        case .seedream: "bytedance.symbols"
        }
    }

    var color: String {
        switch self {
        case .gpt: "#00947A"
        case .nanoBanana: "#E64335"
        case .seedream: "#00A8B2"
        }
    }
}
