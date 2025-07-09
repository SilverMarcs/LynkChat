//
//  ChatListRow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct ChatListRow: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.openWindow) var openWindow
    @Environment(ChatVM.self) private var chatVM
    
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat

    var body: some View {
        row
        .swipeActions(edge: .leading) {
            #if os(macOS)
            if chat.status != .starred {
                Button {
                    SwipeActionTip().invalidate(reason: .actionPerformed)
                    
                    if chatVM.selections.contains(chat) {
                        chatVM.selections.remove(chat)
                    }
                    
                    chat.status = (chat.status == .archived) ? .normal : .archived
                } label: {
                    Label("Archive", systemImage: chat.status == .archived ? "tray.and.arrow.up.fill" : "archivebox")
                }
                .tint(chat.status == .archived ? .blue : .gray)
            }
            #endif

            if chat.status != .archived {
                Button {
                    SwipeActionTip().invalidate(reason: .actionPerformed)
                    chat.status = chat.status == .starred ? .normal : .starred
                } label: {
                    Label(chat.status == .starred ? "Unstar" : "Star", systemImage: chat.status == .starred ? "star.slash" : "star")
                }
                .tint(.orange)
            }
        }
        .swipeActions(edge: .trailing) {
            if chat.status != .starred {
                Button(role: .destructive) {
                    SwipeActionTip().invalidate(reason: .actionPerformed)

                    if chatVM.selections.contains(chat) {
                        chatVM.selections.remove(chat)
                    }
                    
                    // Clean up all messages and message groups first
                    chat.cleanupMessagesAndGroups()
                    // Then delete the chat itself
                    modelContext.delete(chat)
                    
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
            }
        }
        .contextMenu {
            Button {
                Task {
                    let newChat = await chat.copy()
                    newChat.title = "(Ψ) " + newChat.title
                    chatVM.fork(newChat: newChat)
                }
            } label: {
                Label("Fork Chat", systemImage: "arrow.branch")
                    .labelStyle(.titleAndIcon)
            }
        }
    }
    
    var row: some View {
        HStack {
            ListRowImage(model: chat.config.model)
            
            HighlightableTextView(chat.title, highlightedText: chatVM.searchText)
                .lineLimit(1)
                #if os(macOS)
                .font(.headline.weight(.regular))
                #else
                .font(.headline.weight(.medium))
                #endif
                .opacity(0.9)
                .shimmerWithoutRedact(when: chat.isReplying)
            
            Spacer()
            
            if chat.status != .normal {
                Image(systemName: chat.status.systemImageName)
                    .foregroundStyle(chat.status.iconColor)
                    .imageScale(.small)
                    .transition(.symbolEffect(.appear))
            }
        }
    }
}

#Preview {
    List {
        ChatListRow(chat: .mockChat)
            .environment(ChatVM())
    }
    .frame(width: 250)
}
