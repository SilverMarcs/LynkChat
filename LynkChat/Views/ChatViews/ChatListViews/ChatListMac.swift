//
//  ChatListMac.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/07/2025.
//

import SwiftUI
import SwiftData

struct ChatListMac: View {
    @Environment(\.openWindow) var openWindow
    @Environment(GodMode.self) var godMode

    var chats: [Chat]
    var deleteItems: (IndexSet) -> Void

    @Environment(ChatVM.self) var chatVM: ChatVM

    var body: some View {
        @Bindable var chatVM = chatVM

        List(selection: $chatVM.selections) {
            ChatListCards(chatCount: String(chats.count), imageSessionsCount: "↗")
            
            ForEach(chats, id: \.self) { chat in
                ChatListRow(chat: chat)
                    .tag(chat)
                    .deleteDisabled(chat.status == .starred)
                    .listRowSeparator(.visible)
            }
            .onDelete(perform: deleteItems)
        }
        .contextMenu(forSelectionType: Chat.self) { item in
            // Add context menu actions if needed
        } primaryAction: { items in
            for item in items {
                openWindow(value: item.id)
            }
        }
        .task {
            if let first = chats.first, chatVM.selections.isEmpty {
                chatVM.selections = [first]
            }
        }
        .toolbar(removing: .sidebarToggle)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
                    let indices = chatVM.selections.compactMap { chat in
                        chats.firstIndex(of: chat)
                    }
                    deleteItems(IndexSet(indices))
                } label: {
                    Image(systemName: "trash")
                }
                .keyboardShortcut(.delete, modifiers: [.command, .shift])
                .disabled(chatVM.selections.isEmpty)
            }
            
            ToolbarSpacer()
            
            ToolbarItem(placement: .automatic) {
                Menu {
                    ForEach(godMode.availableCases) { model in
                        Button {
                            chatVM.createNewChat(model: model)
                        } label: {
                            Label(model.name, image: model.imageName)
                                .labelStyle(.titleAndIcon)
                        }
                    }
                } label: {
                    Label("New Chat", systemImage: "square.and.pencil")
                } primaryAction: {
                    chatVM.createNewChat()
                }
                .menuIndicator(.hidden)
            }
        }
    }
}
