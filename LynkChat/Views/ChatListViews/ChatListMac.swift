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
    
    var chats: [Chat]
    var deleteItems: (IndexSet) -> Void
    
    @Bindable var chatVM = ChatVM.shared
    
    var body: some View {
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
    }
}
