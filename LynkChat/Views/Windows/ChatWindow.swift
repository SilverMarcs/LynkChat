//
//  MainWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/08/2024.
//

import SwiftUI
import SwiftData

struct ChatWindow: Scene {
    var body: some Scene {
        Window("Chats", id: WindowID.chats) {
            ChatContentView()
        }
        .defaultSize(.init(width: 1200, height: 900))
        .commands {
            ChatCommands()
        }

        WindowGroup(for: Chat.ID.self) { $id in
            if let id = id {
                ChatDetailWrapper(id: id)
                    .environment(ChatVM())
                    .modelContainer(globalContainer)
            } else {
                Text("No ID")
            }
        }
        .restorationBehavior(.disabled)
        .defaultSize(.init(width: 1000, height: 800))
    }
}

struct ChatDetailWrapper: View {
    @Environment(ChatVM.self) private var chatVM
    @Query private var chats: [Chat]
    let id: Chat.ID

    init(id: Chat.ID) {
        self.id = id
        self._chats = Query(filter: #Predicate<Chat> { chat in
            chat.id == id
        })
    }

    var body: some View {
        @Bindable var chatVM = chatVM
        
        if let chat = chats.first {
            ChatDetail(chat: chat)
                .background(.background)
                .searchable(text: $chatVM.searchText)
        } else {
            Text("Chat not found")
        }
    }
}
