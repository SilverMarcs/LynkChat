//
//  ImageServiceTab.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import Foundation

enum ImageServiceTab: String, CaseIterable {
    case parameters = "Parameters"
    case models = "Models"
    
    var imageName: String {
        switch self {
        case .models:
            return "cpu.fill"
        case .parameters:
            return "slider.horizontal.3"
        }
    }
}
