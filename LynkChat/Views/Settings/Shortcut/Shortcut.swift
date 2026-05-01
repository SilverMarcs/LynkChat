//
//  Shortcut.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/11/2024.
//

import Foundation

struct Shortcut: Identifiable {
    var id = UUID()
    let key: String
    let action: String
    
    static let quickPanelShortcuts: [Shortcut] = [
        Shortcut(key: "⌃ + Space", action: "Open Quick Panel")
    ]

    static let chatInteractionShortcuts: [Shortcut] = [
        Shortcut(key: "⌘ + N", action: "New Chat"),
        Shortcut(key: "⌘ + Return", action: "Send Prompt"),
        Shortcut(key: "⌘ + V", action: "Paste File from Clipboard"),
        Shortcut(key: "⌘ + L", action: "Focus Inputbox"),
        Shortcut(key: "⌘ + R", action: "Regenerate Last Message"),
        Shortcut(key: "⌘ + E", action: "Edit Last Prompt"),
        Shortcut(key: "⌘ + K", action: "Rest Context"),
        Shortcut(key: "⌘ + D", action: "Delete Last Message"),
    ]
        
    static let fontSizeShortcuts: [Shortcut] = [
        Shortcut(key: "⌘  + +", action: "Increase Font Size"),
        Shortcut(key: "⌘  + -", action: "Decrease Font Size"),
        Shortcut(key: "⌘  + O", action: "Reset Font Size"),
    ]
    
    static let appSettingsShortcuts: [Shortcut] = [
        Shortcut(key: "⌘ + .", action: "Open Chat Config Menu"),
        Shortcut(key: "⌘ + ,", action: "Open App Settings"),
    ]
}
