//
//  ChatCommands.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData

struct ChatCommands: Commands {
    @Environment(\.modelContext) var modelContext
    @AppStorage("fontSize") var fontSize: Double = 13
    @Environment(ChatVM.self) var chatVM
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button {
                chatVM.createNewChat()
            } label: {
                Label("New Chat", systemImage: "square.and.pencil")
            }
            .keyboardShortcut("n")

            Button {
                chatVM.createTemporaryChat()
            } label: {
                Label("Temporary Chat", systemImage: "bubble.left.and.bubble.right")
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
        }

        CommandGroup(before: .toolbar) {
            Section {
                Button {
                    resetFontSize()
                } label: {
                    Label("Actual Size", systemImage: "1.magnifyingglass")
                }
                .keyboardShortcut("o", modifiers: .command)

                Button {
                    increaseFontSize()
                } label: {
                    Label("Zoom In", systemImage: "plus.magnifyingglass")
                }
                .keyboardShortcut("+", modifiers: .command)

                Button {
                    decreaseFontSize()
                } label: {
                    Label("Zoom Out", systemImage: "minus.magnifyingglass")
                }
                .keyboardShortcut("-", modifiers: .command)
            }
        }
    }
    
    private func increaseFontSize() {
        fontSize = min(fontSize + 1, 25)
    }
    
    private func decreaseFontSize() {
        fontSize = max(fontSize - 1, 8)
    }
    
    private func resetFontSize() {
        fontSize = 13
    }
}
