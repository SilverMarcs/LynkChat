//
//  QuickPanelHeight.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/02/2025.
//

import SwiftUI

enum QuickPanelHeight: Equatable {
    case collapsed(CGFloat = 57)    // Default minimal height
    case files(CGFloat = 170)       // Height when files are present
    case expanded(CGFloat = 500)    // Full height with conversation
    
    var value: CGFloat {
        switch self {
        case .collapsed(let height): return height
        case .files(let height): return height
        case .expanded(let height): return height
        }
    }
}
