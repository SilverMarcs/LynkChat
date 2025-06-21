//
//  LynkChatShortcuts.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/06/2025.
//

import AppIntents

struct LynkChatShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateChatIntent(),
            phrases: [
                "Add a new chat in \(.applicationName)",
                "Create a new chat in \(.applicationName)",
                "Start a chat in \(.applicationName)",
                "Send a message in \(.applicationName)",
                "Ask \(.applicationName)",
                "Chat with \(.applicationName)"
            ],
            shortTitle: "Ask LynkChat AI",
            systemImageName: "message"
        )
        
        AppShortcut(
            intent: QuickResponseIntent(),
            phrases: [
                "Quick response in \(.applicationName)",
                "Quick AI response in \(.applicationName)",
                "Ask AI quickly in \(.applicationName)",
                "Quick question in \(.applicationName)"
            ],
            shortTitle: "Quick AI Response",
            systemImageName: "bolt"
        )
    }
}
