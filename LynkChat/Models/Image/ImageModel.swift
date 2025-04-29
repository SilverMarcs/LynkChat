//
//  ImageModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

enum ImageModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case flux_schnell
    case gpt
    
    static let allCases: [ImageModel] = AppConfig.shared.showDebugMenu ?
    [.flux_schnell, .gpt] :
    [.flux_schnell]

    var id: String {
        switch self {
        case .flux_schnell: "flux"
        case .gpt: "gpt"
        }
    }

    var name: String {
        switch self {
        case .flux_schnell: "Flux"
        case .gpt: "GPT"
        }
    }

    var imageName: String {
        switch self {
            case .flux_schnell: "flux.symbols"
            case .gpt: "openai.symbols"
        }
    }

    var color: String {
        switch self {
        case .flux_schnell: "#6431e2"
        case .gpt: "#00947A"
        }
    }
}
