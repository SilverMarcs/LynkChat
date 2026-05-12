//
//  WindowScenesCollection.swift
//  LynkChat
//
//  Created by Zabir Raihan on 24/12/2024.
//

import SwiftUI
import AppKit

struct WindowScenesCollection: Scene {
    @AppStorage("hideDockIconWhenWindowClosed") private var hideDockIconWhenWindowClosed: Bool = false

    var body: some Scene {
        ChatWindow()
            .environment(\.windowType, .chats)

        ImageWindow()
            .environment(\.windowType, .images)

        SettingsWindow()

        AboutWindow()

        MenuBarExtra("LynkChat", systemImage: "bolt.fill", isInserted: $hideDockIconWhenWindowClosed) {
            MenuBarExtraContent()
        }
    }
}

private struct MenuBarExtraContent: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Open LynkChat") {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: WindowID.chats)
        }
        Divider()
        Button("Quit LynkChat") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
