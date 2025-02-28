//
//  ImageModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import Foundation

enum ImageModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case flux_schnell
    case sdxl
    
    static let allCases: [ImageModel] = [.flux_schnell, .sdxl]

    var id: String {
        switch self {
        case .flux_schnell: "flux"
        case .sdxl: "sdxl"
        }
    }

    var name: String {
        switch self {
        case .flux_schnell: "Flux"
        case .sdxl: "SDXL"
        }
    }

    var imageName: String {
        switch self {
            case .flux_schnell: "flux.symbols"
            case .sdxl: "stability.symbols"
        }
    }

    var color: String {
        switch self {
        case .flux_schnell: "#6431e2"
        case .sdxl: "d52e1f"
        }
    }
}
