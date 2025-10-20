//
//  VideoGenerationModel.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/10/2025.
//

import Foundation

enum VideoGenerationModel: String, Identifiable, Hashable, Codable, Equatable, CaseIterable, ModelImageProvider {
    case seedance

    var id: String { rawValue }

    var name: String {
        switch self {
        case .seedance: "Seedance"
        }
    }
    
    var color: String {
        switch self {
        case .seedance: "#00A8B2"
        }
    }
    
    var imageName: String {
        switch self {
        case .seedance: "bytedance.symbols"
        }
    }
}
