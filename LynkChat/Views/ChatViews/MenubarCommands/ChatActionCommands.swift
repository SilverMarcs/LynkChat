//
//  ChatActionCommands.swift
//  LynkChat
//
//  Created by Zabir Raihan on 12/05/2026.
//

import SwiftUI

extension FocusedValues {
    @Entry var activeChat: Chat?
}

struct ChatActionCommands: Commands {
    @FocusedValue(\.activeChat) private var chat: Chat?

    var body: some Commands {
        if let chat {
            CommandMenu("Chat") {
                Section {
                    Button(chat.isReplying ? "Stop Message" : "Send Message") {
                        if chat.isReplying {
                            chat.stopStreaming()
                        } else {
                            Task { await chat.sendInput() }
                        }
                    }
                    .keyboardShortcut(chat.isReplying ? "d" : .return)

                    Button("Edit Last Message") {
                        guard let lastUserMessage = chat.currentThread.last(where: { $0.role == .user }) else { return }
                        chat.inputManager.setupEditing(chat: chat, message: lastUserMessage)
                    }
                    .keyboardShortcut("e")
                    .disabled(chat.status == .quick || chat.isReplying)

                    Button("Regenerate Last Message") {
                        guard !chat.isReplying, let last = chat.currentThread.last else { return }
                        Task { await chat.regenerate(message: last) }
                    }
                    .keyboardShortcut("r")
                    .disabled(chat.isReplying)
                }

                Section {
                    Button("Reset Context") {
                        guard !chat.isReplying, let last = chat.currentThread.last else { return }
                        chat.resetContext(at: last)
                    }
                    .keyboardShortcut("k")
                    .disabled(chat.isReplying)

                    Button("Delete Last Message", role: .destructive) {
                        chat.deleteLastMessage()
                        chat.errorMessage = nil
                    }
                    .keyboardShortcut(.delete)
                }
            }
        }
    }
}
