//
//  MessageContextMenu.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct MessageContextMenu: View {
    @Environment(\.chat) var chat
    @Bindable var group: MessageGroup
    var toggleTextSelection: (() -> Void)? = nil

    var body: some View {
        Section {
            if !group.isSplitView {
                // Regenerate Button
                Button {
                    Task {
                        await chat.regenerate(message: group)
                    }
                } label: {
                    Label("Regenerate", systemImage: "arrow.2.circlepath")
                }
            }
            
            if group.role == .user {
                // Edit Button
                Button(action: { chat.inputManager.setupEditing(message: group) }) {
                    Label("Edit", systemImage: "pencil.and.outline")
                }
                .help("Edit")
            }
        }
        
        Section {
            // Copy Buttons
            if !group.dataFiles.isEmpty {
                Button {
                    var finalString = group.dataFiles.map { $0.formattedTextContent }.joined()
                    finalString += group.content
                    finalString.copyToPasteboard()
                } label: {
                    Label("Copy Files", systemImage: "doc.richtext")
                }
                .frame(width: 15)
            }
            
            Button {
                group.content.copyToPasteboard()
            } label: {
                Label("Copy", systemImage: "paperclip")
            }
            .contentTransition(.symbolEffect(.replace))
            .frame(width: 15)
        }

        Section {
            #if !os(macOS)
            if let toggleTextSelection = toggleTextSelection {
                // Select Text Button
                Button {
                    toggleTextSelection()
                } label: {
                    Label("Select Text", systemImage: "text.cursor")
                }
                .help("Select Text")
            }
            #endif
            
            // Fork Button
            Button {
                Task {
                    let newChat = await chat.copy(from: group.activeMessage)
                    newChat.title = "(Ψ) " + newChat.title
                    ChatVM.shared.fork(newChat: newChat)
                }
            } label: {
                Label("Fork Chat", systemImage: "arrow.branch")
            }
            .help("Fork Chat")
        }
        
        Section {
            // Reset Context Button
            Button(action: { chat.resetContext(at: group) }) {
                Label("Reset Context", systemImage: "eraser")
            }
            .help("Reset Context")
            
            if chat.currentThread.last == group {
                Button(role: .destructive, action: chat.deleteLastMessage) {
                    Label("Delete All Messages", systemImage: "trash")
                }
            }
            
            if group.allMessages.count > 1 {
                Button(role: .destructive, action: { group.deleteActiveMessage() }) {
                    Label("Delete Message", systemImage: "minus.circle")
                }
                .help("Delete Message")
            }
        }
    }
}

#Preview {
    VStack {
        MessageContextMenu(group: .mockUserGroup)
        MessageContextMenu(group: .mockAssistantGroup)
    }
    .frame(width: 500)
    .padding()
}
