//
//  ShortcutRow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 02/11/2025.
//

import SwiftUI

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
