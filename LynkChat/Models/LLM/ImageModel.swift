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
        case .flux_schnell: "black-forest-labs/FLUX.1-schnell"
        case .dall_e_2: "dall-e-2"
        case .dall_e_3: "dall-e-3"
        }
    }

    var name: String {
        switch self {
        case .flux_schnell: "Flux-1 Schnell"
        case .dall_e_2: "DALL-E 2"
        case .dall_e_3: "DALL-E 3"
        }
    }

    var imageName: String {
        switch self {
            case .flux_schnell: "together.SFSymbol"
            case .dall_e_2, .dall_e_3: "openai.SFSymbol"
        }
    }

    var color: String {
        switch self {
        case .flux_schnell: "#E6784B"
        case .dall_e_2, .dall_e_3: "#00947A"
        }
    }
}
