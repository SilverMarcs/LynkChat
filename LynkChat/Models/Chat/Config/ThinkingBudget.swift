//
//  ThinkingBudget.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import Foundation

enum ThinkingBudget: String, CaseIterable, Codable, Sendable {
    case none
    case low
    case medium
    case high
    
    var displayName: String {
        switch self {
        case .none: "None"
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }
    
    var systemImage: String {
        switch self {
        case .none: "minus.circle"
        case .low: "gauge.low"
        case .medium: "gauge.medium"
        case .high: "gauge.high"
        }
    }
}
