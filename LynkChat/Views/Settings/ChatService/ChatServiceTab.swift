//
//  ChatServiceTab.swift
//  LynkChat
//
//  Created by Zabir Raihan on 01/01/2025.
//

import Foundation

enum ChatServiceTab: String, CaseIterable {
    case models = "Models"
    case parameters = "Parameters"
    
    var imageName: String {
        switch self {
        case .models:
            return "cpu.fill"
        case .parameters:
            return "slider.horizontal.3"
        }
    }
}
