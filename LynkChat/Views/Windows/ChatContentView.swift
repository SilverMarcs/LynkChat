//
//  ChatContentView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData

struct ChatContentView: View {
    @Environment(\.undoManager) var undoManager
    @Environment(\.modelContext) var modelContext
    @Environment(\.isSearching) private var isSearching
    @Environment(ChatVM.self) var chatVM
    
    @ObservedObject var config = AppConfig.shared
    
    @FocusState private var isSearchFieldFocused: FocusedField?
    
    var body: some View {
        @Bindable var chatVM = chatVM
        
        NavigationSplitView {
            if !chatVM.debouncedSearchText.isEmpty {
                MessageGroupList(searchText: chatVM.debouncedSearchText)
                    .navigationSplitViewColumnWidth(min: 270, ideal: 300, max: 400)
            } else {
                ChatList(status: chatVM.statusFilter, searchText: chatVM.debouncedSearchText)
                    .navigationSplitViewColumnWidth(min: 270, ideal: 300, max: 400)
            }
        } detail: {
            if let chat = chatVM.activeChat {
                ChatDetail(chat: chat)
                #if os(macOS)
                    .frame(minWidth: 600)
                #endif
                    .id(chat.id)
            } else {
                Text(chatVM.selections.count > 0
                    ? "^[\(chatVM.selections.count) Chat](inflect: true) Selected"
                    : "Select or create a chat to get started")
                    .font(.title)
                    .fullScreenBackground()
            }
        }
        .background(.background)
        .onChange(of: undoManager, initial: true) {
            modelContext.undoManager = undoManager
        }
        .sheet(isPresented: .constant(!config.hasCompletedOnboarding)) {
            OnboardingView()
        }
        .searchable(text: $chatVM.searchText, placement: searchPlacement)
        .searchFocused($isSearchFieldFocused, equals: .searchBox)
        .onChange(of: chatVM.searchText) {
            chatVM.updateSearchText(chatVM.searchText)
            
            // Keep password verification functionality
            if PasswordHelper.verifyPassword(chatVM.searchText) {
                config.showDebugMenu = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Search") {
                    isSearchFieldFocused = .searchBox
                }
                .keyboardShortcut("f")
            }
        }
    }
    
    private var searchPlacement: SearchFieldPlacement {
        #if os(macOS)
        return .sidebar
        #else
        return .automatic
        #endif
    }
}

#Preview {
    ChatContentView()
        .modelContainer(for: Chat.self, inMemory: true)
        .environment(ChatVM())
}
