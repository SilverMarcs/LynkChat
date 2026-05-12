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
                    Button {
                        if chat.isReplying {
                            chat.stopStreaming()
                        } else {
                            Task { await chat.sendInput() }
                        }
                    } label: {
                        Label(
                            chat.isReplying ? "Stop Message" : "Send Message",
                            systemImage: chat.isReplying ? "stop.circle" : "paperplane"
                        )
                    }
                    .keyboardShortcut(chat.isReplying ? "d" : .return)

                    Button {
                        guard let lastUserMessage = chat.currentThread.last(where: { $0.role == .user }) else { return }
                        chat.inputManager.setupEditing(chat: chat, message: lastUserMessage)
                    } label: {
                        Label("Edit Last Message", systemImage: "pencil")
                    }
                    .keyboardShortcut("e")
                    .disabled(chat.status == .quick || chat.isReplying)

                    Button {
                        guard !chat.isReplying, let last = chat.currentThread.last else { return }
                        Task { await chat.regenerate(message: last) }
                    } label: {
                        Label("Regenerate Last Message", systemImage: "arrow.clockwise")
                    }
                    .keyboardShortcut("r")
                    .disabled(chat.isReplying)
                }

                Section {
                    Button {
                        guard !chat.isReplying, let last = chat.currentThread.last else { return }
                        chat.resetContext(at: last)
                    } label: {
                        Label("Reset Context", systemImage: "eraser")
                    }
                    .keyboardShortcut("k")
                    .disabled(chat.isReplying)

                    Button(role: .destructive) {
                        chat.deleteLastMessage()
                        chat.errorMessage = nil
                    } label: {
                        Label("Delete Last Message", systemImage: "trash")
                    }
                    .keyboardShortcut(.delete)
                }
            }
        }
    }
}
