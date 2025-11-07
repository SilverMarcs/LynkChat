//
//  MessageContextMenu.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct MessageContextMenu: View {
    @Environment(\.chat) var chat
    @Environment(ChatVM.self) var chatVM
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
                Button(action: { chat.inputManager.setupEditing(chat: chat, message: group) }) {
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
            
            // Copy All Messages Button (only show if there are multiple messages)
            if group.allMessages.count > 1 {
                Button {
                    copyAllMessages()
                } label: {
                    Label("Copy All Messages", systemImage: "doc.on.doc")
                }
                .frame(width: 15)
            }
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
                    chatVM.fork(newChat: newChat)
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
    
    private func copyAllMessages() {
        let allMessagesText = group.allMessages.map { message in
            "\(message.model.name):\n\(message.content)"
        }.joined(separator: "\n\n")
        
        allMessagesText.copyToPasteboard()
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
