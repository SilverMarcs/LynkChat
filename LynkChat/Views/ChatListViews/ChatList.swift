//
//  ChatList.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftData
import SwiftUI

struct ChatList: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.isSearching) private var isSearching
    @Environment(ChatVM.self) var chatVM
    @Environment(\.modelContext) var modelContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var config = AppConfig.shared
    
    @Query var chats: [Chat] // see init method below
    
    var body: some View {
        @Bindable var chatVM = chatVM

        List(selection: $chatVM.selections) {
            #if os(macOS)
            ChatListCards(source: .chats, chatCount: String(chats.count), imageSessionsCount: "↗")

            if isSearching {
                Text("Press Enter to search")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .bold()
                    .listRowSeparator(.hidden)
            }
            #endif
            
            if isSearching && chats.isEmpty {
                ContentUnavailableView.search
            } else {
                ForEach(chats, id: \.self) { chat in
                    ChatListRow(chat: chat)
                        .tag(chat)
                        .deleteDisabled(chat.status == .starred)
                        #if os(macOS)
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(Color.gray.opacity(0.2))
                        #endif
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle("Chats")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            toolbar
        }
        .task {
            if horizontalSizeClass == .regular, let first = chats.first, chatVM.selections.isEmpty {
                chatVM.selections = [first]
            }
        }
        #if os(macOS)
        .contextMenu(forSelectionType: Chat.self) { item in
            
        } primaryAction: { items in
            for item in items {
                openWindow(value: item.id)
            }
        }
        #else
        .fullScreenCover(isPresented: $config.showCamera) {
            CameraView(chatVM: chatVM)
                .ignoresSafeArea()
        }
        #endif
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
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarSpacer()
        
        #if os(macOS)
        ToolbarItem(placement: .keyboard) {
            Button(action: {
                // Get the indices of the selected chats
                let indices = chatVM.selections.compactMap { chat in
                    chats.firstIndex(of: chat)
                }
                // Create an IndexSet from the indices
                let indexSet = IndexSet(indices)
                // Perform the delete operation
                deleteItems(offsets: indexSet)
            }) {
                Image(systemName: "trash")
            }
            .keyboardShortcut(.delete, modifiers: [.command])
            .disabled(chatVM.selections.count <= 1)
        }
        #endif
        
        ToolbarSpacer(placement: placement)
        
        ToolbarItem(placement: placement) {
            Menu {
                ForEach(ChatModel.allCases) { model in
                    Button {
                        chatVM.createNewChat(model: model)
                    } label: {
                        Label(model.name, image: model.imageName)
                            .labelStyle(.titleAndIcon)
//                            .labelStyle(.titleOnly)
                    }
                }
            } label: {
                Label("New Chat", systemImage: "square.and.pencil")
            } primaryAction: {
                chatVM.createNewChat()
            }
            .menuIndicator(.hidden)
            .popoverTip(NewChatTip())
        }
    }
    
    var placement: ToolbarItemPlacement {
        #if os(macOS)
        return .primaryAction
        #else
        return .bottomBar
        #endif
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
