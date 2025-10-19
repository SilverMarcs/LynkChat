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
    @State var config = AppConfig()
    @Environment(ChatVM.self) var chatVM
    @AppStorage("fontSize") var fontSize: Double = Double.defaultFontSize
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Chat") {
                chatVM.createNewChat()
            }
            .keyboardShortcut("n")
            
            Button("Temporary Chat") {
                chatVM.createTemporaryChat()
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
        fontSize = min(fontSize + 1, 25)
    }
    
    private func decreaseFontSize() {
        fontSize = max(fontSize - 1, 8)
    }
    
    private func resetFontSize() {
        fontSize = Double.defaultFontSize
    }
}
