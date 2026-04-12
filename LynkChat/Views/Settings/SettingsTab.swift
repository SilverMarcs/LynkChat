//
//  SettingsTab.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/11/2024.
//

import SwiftUI

enum SettingsCategory: String, Hashable, CaseIterable {
    case general = "General"
    case quickPanel = "Quick Panel"
    case shortcuts = "Shortcuts"
    case chatService = "Chat Service"
    case imageService = "Image Service"
    case about = "About"
    case debug = "Debug"
    
    var systemImage: String {
        switch self {
        case .general: return "gear"
        case .quickPanel: return "bolt.fill"
        case .shortcuts: return "command"
        case .chatService: return "quote.bubble"
        case .imageService: return "photo"
        case .about: return "info.circle"
        case .debug: return "ladybug"
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .general: GeneralSettings()
        case .quickPanel: QuickPanelSettings()
        case .shortcuts: ShortcutSettings()
        case .chatService: ChatServiceSettings()
        case .imageService: ImageServiceSettings()
        case .about: AboutSettings()
        case .debug: DebugSettings()
        }
    }
}
