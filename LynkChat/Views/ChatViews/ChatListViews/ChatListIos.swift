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
    @Environment(\.editMode) private var editMode
    @Environment(\.setWindowType) private var setWindowType
    
    var chats: [Chat]
    var deleteItems: (IndexSet) -> Void
    
    @AppStorage("autoCreateChatOnLaunch") var autoCreateChatOnLaunch: Bool = false
 
    @State private var showSettings = false
    @State private var initedLaunch = false
    
    @Namespace private var transition
    
    var body: some View {
        @Bindable var chatVM = chatVM

        List(selection: $chatVM.selections) {
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
            }
        }
        .contentMargins(.top, 10)
        .onAppear {
            if autoCreateChatOnLaunch {
                if !initedLaunch {
                    if let firstChat = chats.first, firstChat.currentThread.isEmpty {
                        chatVM.selectChat(firstChat)
                    } else {
                        chatVM.createNewChat()
                    }
                    initedLaunch = true
                    
                }
            }
        }
        .onChange(of: chatVM.selections) { _, newValue in
            let isEditing = editMode?.wrappedValue.isEditing == true
            handleSelectionChange(newValue, isEditing: isEditing)
        }
        .onChange(of: chatVM.chatPath) {
            handlePathChange()
        }
        .navigationDestination(for: Chat.self) { chat in
            ChatDetail(chat: chat)
                .id(chat.id)
        }
        .toolbar {
            if editMode?.wrappedValue.isEditing == true {
                ToolbarItem(placement: .bottomBar) {
                    Button("Cancel") {
                        withAnimation {
                            editMode?.wrappedValue = .inactive
                        }
                    }
                }
            }
            
            if editMode?.wrappedValue.isEditing == false {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
            }
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
            
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    EditButton()

                    Button {
                        setWindowType(.images)
                    } label: {
                        Label("Images", systemImage: "photo.on.rectangle.angled")
                    }
                } label: {
                    Label("Settings", systemImage: "gear")
                } primaryAction: {
                    showSettings = true
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                        .navigationTransition(.zoom(sourceID: "settings", in: transition))
                }
            }
            .matchedTransitionSource(id: "settings", in: transition)
            
            if editMode?.wrappedValue.isEditing == true {
                ToolbarItem(placement: .bottomBar) {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        let selectedChats = chatVM.selections
                        let indices = selectedChats.compactMap { chat in
                            chats.firstIndex(of: chat)
                        }
                        deleteItems(IndexSet(indices))
                        chatVM.selections.removeAll()
                    }
                    .disabled(chatVM.selections.isEmpty)
                }
            }
             
            if editMode?.wrappedValue.isEditing == false {
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

    private func handleSelectionChange(_ newValue: Set<Chat>, isEditing: Bool) {
        guard !isEditing else { return }

        if newValue.count == 1, let chat = newValue.first {
            if let current = chatVM.chatPath.last, current == chat {
                chatVM.currentChat = chat
                return
            }
            if chatVM.currentChat == chat {
                return
            }
            chatVM.selectChat(chat)
        } else if newValue.isEmpty {
            chatVM.currentChat = nil
        }
    }

    private func handlePathChange() {
        if let chat = chatVM.chatPath.last {
            if chatVM.selections != [chat] {
                chatVM.selections = [chat]
            }
            chatVM.currentChat = chat
        } else {
            chatVM.selections.removeAll()
            chatVM.currentChat = nil
        }
    }
}
