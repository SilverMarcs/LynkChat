//
//  ImageEditingModel.swift
//  LynkChat
//
//  Created by GitHub Copilot on 11/10/2025.
//

import Foundation

enum ImageEditingModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case seedream
    case nanoBanana

    var id: String { rawValue }

    var name: String {
        switch self {
        case .seedream: "Seedream"
        case .nanoBanana: "Banana"
        }
    }
    
    var apiPath: String {
        switch self {
        case .seedream: "/api/v3/bytedance/seedream-v4/edit"
        case .nanoBanana: "/api/v3/google/nano-banana/edit"
        }
    }
    
    var color: String {
        switch self {
        case .nanoBanana: "#E64335"
        case .seedream: "#6431e2"        }
    }
    
    var imageName: String {
        "storm.SFSymbol"
    }
}
