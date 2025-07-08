//
//  ChatListIos.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/07/2025.
//

import SwiftUI
import SwiftData

struct ChatListIos: View {
    @Environment(ChatVM.self) var chatVM
    @ObservedObject var config = AppConfig.shared
    @Environment(\.modelContext) var modelContext
    
    var chats: [Chat]
    var deleteItems: (IndexSet) -> Void
    
    var body: some View {
        List {
            if chats.isEmpty && config.showCamera == false {
                ContentUnavailableView.search
            } else {
                ForEach(chats, id: \.self) { chat in
                    NavigationLink(value: chat) {
                        ChatListRow(chat: chat)
                    }
                    .tag(chat)
                    .deleteDisabled(chat.status == .starred)
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationDestination(for: Chat.self) { chat in
            ChatDetail(chat: chat)
                .id(chat.id)
        }
        .fullScreenCover(isPresented: $config.showCamera) {
            CameraView(chatVM: chatVM)
                .ignoresSafeArea()
        }
    }
}
