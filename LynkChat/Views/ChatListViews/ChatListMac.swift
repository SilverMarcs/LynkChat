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
    @Environment(\.isSearching) private var isSearching
    @Environment(ChatVM.self) var chatVM
    @Environment(\.modelContext) var modelContext
    
    var chats: [Chat]
    var deleteItems: (IndexSet) -> Void
    
    var body: some View {
        @Bindable var chatVM = chatVM
        
        List(selection: $chatVM.selections) {
            ChatListCards(source: .chats, chatCount: String(chats.count), imageSessionsCount: "↗")
            if isSearching && chats.isEmpty {
                ContentUnavailableView.search
            } else {
                ForEach(chats, id: \.self) { chat in
                    ChatListRow(chat: chat)
                        .tag(chat)
                        .deleteDisabled(chat.status == .starred)
                        .listRowSeparator(.visible)
                }
                .onDelete(perform: deleteItems)
            }
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
    }
}
