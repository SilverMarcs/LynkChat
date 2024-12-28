//
//  SettingsTab.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/11/2024.
//

import Foundation

enum SettingsTab {
    case general
    case appearance
    #if os(macOS)
    case quickPanel
    case shortcuts
    #endif
    case tools
    case chat
    case image
    case providers
    case guides
    case about
    #if DEBUG
    case debug
    #endif
}
