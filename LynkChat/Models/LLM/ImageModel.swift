//
//  ImageModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

enum ImageModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case flux_schnell
    case dall_e_2
    case dall_e_3

    var id: String {
        switch self {
        case .flux_schnell: "flux-schnell"
        case .dall_e_2: "dall-e-2"
        case .dall_e_3: "dall-e-3"
        }
    }

    var name: String {
        switch self {
        case .flux_schnell: "Flux Schnell"
        case .dall_e_2: "DALL-E 2"
        case .dall_e_3: "DALL-E 3"
        }
    }

    var imageName: String {
        switch self {
            case .flux_schnell: "flux.symbols"
            case .dall_e_2, .dall_e_3: "openai.symbols"
        }
    }

    var color: String {
        switch self {
        case .flux_schnell: "#6431e2"
        case .dall_e_2, .dall_e_3: "#00947A"
        }
    }
}
