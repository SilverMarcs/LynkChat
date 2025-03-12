//
//  Temperature.swift
//  LynkChat
//
//  Created by Zabir Raihan on 02/03/2025.
//

import Foundation

enum Temperature: String, CaseIterable, Codable {
    case precise
    case balanced
    case creative
    
    var name: String {
        switch self {
        case .precise:
            return "Precise"
        case .balanced:
            return "Balanced"
        case .creative:
            return "Creative"
        }
    }
    
    var value: Double {
        switch self {
        case .precise:
            return 0.3
        case .balanced:
            return 0.7
        case .creative:
            return 1.0
        }
    }
    
}
