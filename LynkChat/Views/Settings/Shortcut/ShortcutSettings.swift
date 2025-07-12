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
            LabeledContent {
                Text("⌥ + Space")
            } label: {
                Text("Quick Panel Shortcut")
            }

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

struct ShortcutRow: View {
    var shortcut: Shortcut

    var body: some View {
        LabeledContent {
            Text(shortcut.action)
                .foregroundStyle(.primary)
        } label: {
            Text(shortcut.key)
                .monospaced()
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ShortcutSettings()
}
