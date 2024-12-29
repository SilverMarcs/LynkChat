//
//  ChatServiceTab.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import Foundation

enum ChatServiceTab: String, CaseIterable {
    case models = "Models"
    case parameters = "Parameters"
    case plugins = "Plugins"
    
    var imageName: String {
        switch self {
        case .models:
            return "cpu.fill"
        case .parameters:
            return "slider.horizontal.3"
        case .plugins:
            return "puzzlepiece"
        }
    }
}
