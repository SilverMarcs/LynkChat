//
//  ThinkingBudget.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import Foundation

enum ThinkingBudget: String, CaseIterable, Codable {
    case none
    case low
    case medium
    case hight
    
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
