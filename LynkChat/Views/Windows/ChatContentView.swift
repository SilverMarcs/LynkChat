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
    
    @ObservedObject var config = AppConfig.shared
    
    @Environment(ChatVM.self) var chatVM: ChatVM
    @State var searchText = ""
    
    var body: some View {
        
        NavigationSplitView {
            ChatList(status: chatVM.statusFilter, searchText: searchText)
                .navigationSplitViewColumnWidth(min: 270, ideal: 300, max: 400)
        } detail: {
            if let chat = chatVM.activeChat {
                ChatDetail(chat: chat)
                    .frame(minWidth: 600)
            } else {
                Text(chatVM.selections.count > 0
                    ? "^[\(chatVM.selections.count) Chat](inflect: true) Selected"
                    : "Select or create a chat to get started")
                    .font(.title)
            }
        }
        .onAppear {
            modelContext.undoManager = undoManager
        }
        .sheet(isPresented: .constant(!config.hasCompletedOnboarding)) {
            OnboardingView()
        }
        .searchable(text: $searchText, placement: .sidebar)
//        .searchFocused($isSearchFieldFocused, equals: .searchBox)
//        .onChange(of: chatVM.searchText) {
//            chatVM.updateSearchText(chatVM.searchText)
//            
//            // Keep password verification functionality
//            if PasswordHelper.verifyPassword(chatVM.searchText) {
//                config.showDebugMenu = true
//            }
//        }
    }
}

#Preview {
    ChatContentView()
        .modelContainer(for: Chat.self, inMemory: true)
}
