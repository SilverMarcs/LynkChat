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
    case chat
    case image
    case about
    case debug
}
