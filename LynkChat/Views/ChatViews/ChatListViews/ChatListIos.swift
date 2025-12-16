//
//  ChatListIos.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/07/2025.
//

import SwiftUI
import SwiftData
import AppIntents

struct ChatListIos: View {
    @Environment(\.modelContext) var modelContext
    @Environment(ChatVM.self) var chatVM
    
    var chats: [Chat]
    var deleteItems: (IndexSet) -> Void
    
    @AppStorage("autoCreateChatOnLaunch") var autoCreateChatOnLaunch: Bool = false
    @State private var showSettings = false
    
    var body: some View {
        List {
            if chats.isEmpty {
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
        .onAppear {
            if autoCreateChatOnLaunch {
                if let firstChat = chats.first, firstChat.currentThread.isEmpty {
                    chatVM.chatPath.append(firstChat)
                } else {
                    chatVM.createNewChat()
                }
            }
        }
        .navigationDestination(for: Chat.self) { chat in
            ChatDetail(chat: chat)
                .id(chat.id)
        }
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.flexible, placement: .bottomBar)
            
            ToolbarItem(placement: .primaryAction) {
                Button("Settings", systemImage: "gear") {
                    showSettings = true
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Menu {
                    ForEach(ChatModel.allCases) { model in
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
