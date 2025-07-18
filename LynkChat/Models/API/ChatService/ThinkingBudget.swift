//
//  ThinkingBudget.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import Foundation

enum ThinkingBudget: Int, CaseIterable, Codable {
    case none = 0
    case low = 1024
    case medium = 4096
    case hight = 8192
    
    var displayName: String {
        switch self {
        case .none: "None"
        case .low: "Low"
        case .medium: "Medium"
        case .hight: "High"
        }
    }
    
    var systemImage: String {
        switch self {
        case .none: "minus.circle"
        case .low: "gauge.low"
        case .medium: "gauge.medium"
        case .hight: "gauge.high"
        }
    }
    
    var description: String {
        return String(self.rawValue)
    }
}
