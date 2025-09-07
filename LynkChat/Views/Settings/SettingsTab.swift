//
//  SettingsTab.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/11/2024.
//

import Foundation

enum SettingsTab: String, Codable {
    case general
    #if os(macOS)
    case quickPanel
    case shortcuts
    #endif
    case rag
    case audio
    case chat
    case image
    case about
    case debug
}
