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
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
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
        .sheet(isPresented: .constant(!hasCompletedOnboarding)) {
            OnboardingView()
        }
        .searchable(text: $searchText, placement: .sidebar)
//        .inspector(isPresented: .constant(true)) {
//            if chatVM.selections.count == 1, let first = chatVM.selections.first {
//                ChatInspector(chat: first)
//            }
//        }
    }
}

#Preview {
    ChatContentView()
        .modelContainer(for: Chat.self, inMemory: true)
}
