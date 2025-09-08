//
//  ImageModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

enum ImageModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case flux
    case gpt
    case grok
    case imagen

    var id: String {
        switch self {
        case .flux: "flux"
        case .gpt: "gpt"
        case .grok: "grok"
        case .imagen: "imagen"
        }
    }

    var name: String {
        switch self {
        case .flux: "Flux"
        case .gpt: "GPT"
        case .grok: "Grok"
        case .imagen: "Imagen"
        }
    }

    var imageName: String {
        switch self {
        case .flux: "flux.symbols"
        case .gpt: "openai.symbols"
        case .grok: "xai.symbols"
        case .imagen: "gemini.symbols"
        }
    }

    var color: String {
        switch self {
        case .flux: "#6431e2"
        case .gpt: "#00947A"
        case .grok: "#222222"
        case .imagen: "#E64335"
        }
    }
}
