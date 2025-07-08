//
//  ChatList.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftData
import SwiftUI

struct ChatList: View {
    @Environment(ChatVM.self) var chatVM
    @Environment(\.openWindow) var openWindow
    @Environment(\.isSearching) private var isSearching
    @Environment(\.modelContext) var modelContext
    
    @ObservedObject var config = AppConfig.shared
    
    @Query var chats: [Chat] // see init method below
    
    var body: some View {
        Group {
            #if os(macOS)
            ChatListMac(chats: chats, deleteItems: deleteItems)
            #else
            ChatListIos(chats: chats, deleteItems: deleteItems)
            #endif
        }
        .navigationTitle("Chats")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ChatListToolbar(
                chats: chats,
                deleteItems: deleteItems
            )
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let chat = chats[index]
            
            // Skip starred chats
            if chat.status == .starred {
                continue
            }
            
            // Remove from selections if selected
            if chatVM.selections.contains(chat) {
                chatVM.selections.remove(chat)
            }
            
            // Clean up all messages and message groups first
            chat.cleanupMessagesAndGroups()
            
            // Then delete the chat itself
            modelContext.delete(chat)
        }
    }
    
    init(status: ChatStatus, searchText: String) {
        let statusId = status.id
        let normalId = ChatStatus.normal.id
        let starredId = ChatStatus.starred.id
        
        let sortDescriptor = SortDescriptor(\Chat.date, order: .reverse)
        
        let statusPredicate: Predicate<Chat>
        if status == .normal {
            statusPredicate = #Predicate<Chat> {
                $0.statusId == normalId || $0.statusId == starredId
            }
        } else {
            statusPredicate = #Predicate<Chat> {
                $0.statusId == statusId
            }
        }
        
        if searchText.count >= 2 {
            let searchPredicate = #Predicate<Chat> {
                $0.title.localizedStandardContains(searchText)
            }
            
            // Combine search and status predicates
            let combinedPredicate = #Predicate<Chat> {
                statusPredicate.evaluate($0) && searchPredicate.evaluate($0)
            }
            
            _chats = Query(filter: combinedPredicate, sort: [sortDescriptor], animation: .default)
        } else {
            // When not searching, we only apply the status filter
            _chats = Query(filter: statusPredicate, sort: [sortDescriptor], animation: .default)
        }
    }
}

#Preview {
    ChatList(status: .normal, searchText: "")
        .frame(width: 400)
        .environment(ChatVM())
}
