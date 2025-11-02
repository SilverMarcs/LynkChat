//
//  ShortcutSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct ShortcutSettings: View {
    var body: some View {
        Form {
            #if os(macOS)
            Section("Quick Panel") {
                ForEach(Shortcut.quickPanelShortcuts, id: \.id) { shortcut in
                    ShortcutRow(shortcut: shortcut)
                }
            }
            #endif

            Section("Chat Interaction") {
                ForEach(Shortcut.chatInteractionShortcuts, id: \.id) { shortcut in
                    ShortcutRow(shortcut: shortcut)
                }
            }

            Section("Application Settings") {
                ForEach(Shortcut.appSettingsShortcuts, id: \.id) { shortcut in
                    ShortcutRow(shortcut: shortcut)
                }
            }

            Section("Font Size Adjustment") {
                ForEach(Shortcut.fontSizeShortcuts, id: \.id) { shortcut in
                    ShortcutRow(shortcut: shortcut)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Keyboard Shortcuts")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    ShortcutSettings()
}
