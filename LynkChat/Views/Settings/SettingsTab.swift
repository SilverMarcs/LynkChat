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
    case audioService = "Audio Service"
    case chatService = "Chat Service"
    case imageService = "Image Service"
    case about = "About"
    
    var systemImage: String {
        switch self {
        case .general: return "gear"
        case .quickPanel: return "bolt.fill"
        case .shortcuts: return "command"
        case .audioService: return "waveform"
        case .chatService: return "quote.bubble"
        case .imageService: return "photo"
        case .about: return "info.circle"
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .general: GeneralSettings()
        case .quickPanel: QuickPanelSettings()
        case .shortcuts: ShortcutSettings()
        case .audioService: AudioServiceSettings()
        case .chatService: ChatServiceSettings()
        case .imageService: ImageServiceSettings()
        case .about: AboutSettings()
        }
    }
}
