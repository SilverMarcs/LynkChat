//
//  ChatCommands.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData

struct ChatCommands: Commands {
    @Environment(ChatVM.self) var chatVM
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = AppConfig.shared
    @FocusState var isFocused: FocusedField?
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Chat") {
                modelContext.insert(Chat())
            }
            .keyboardShortcut("n")
            
            Button("Temporary Chat") {
                let chat = Chat()
                chat.status = .temporary
                modelContext.insert(chat)
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
        }
        
        CommandGroup(before: .toolbar) {
            Section {
                Button("Actual Size") {
                    resetFontSize()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Zoom In") {
                    increaseFontSize()
                }
                .keyboardShortcut("+", modifiers: .command)
                
                Button("Zoom Out") {
                    decreaseFontSize()
                }
                .keyboardShortcut("-", modifiers: .command)
            }
        }
    }
    
    private func increaseFontSize() {
        config.fontSize = min(config.fontSize + 1, 25)
    }
    
    private func decreaseFontSize() {
        config.fontSize = max(config.fontSize - 1, 8)
    }
    
    private func resetFontSize() {
        config.fontSize = 13
    }
}
