//
//  ChatVM.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Observable class ChatVM {
    var selections: Set<Chat> = []
    
    var statusFilter: ChatStatus = .normal
    
    public var activeChat: Chat? {
        get {
            guard selections.count == 1 else { return nil }
            return selections.first
        }
        set {
            selections = newValue.map { [$0] } ?? []
        }
    }
    
    @MainActor
    func fork(newChat: Chat) {
        let modelContext = DatabaseService.shared.modelContext
        modelContext.insert(newChat)
        #if os(macOS)
        self.selections = [newChat]
        #else
        self.selections = []
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selections = [newChat]
        }
        #endif
    }
    
    @MainActor
    func createNewChat() {
        let newChat = Chat()
        DatabaseService.shared.modelContext.insert(newChat)
        self.selections = [newChat]
    }
    
    @MainActor
    func createTemporaryChat() {
        let chat = Chat()
        chat.status = .temporary
        DatabaseService.shared.modelContext.insert(chat)
        self.selections = [chat]
    }
    
    // MARK: - Navigation
    func goToNextChat(chats: [Chat]) {
        guard let activeChat = activeChat,
              let index = chats.firstIndex(of: activeChat),
              index < chats.count - 1 else { return }
        
        let nextChat = chats[index + 1]
        selections = [nextChat]
    }

    func goToPreviousChat(chats: [Chat]) {
        guard let activeChat = activeChat,
              let index = chats.firstIndex(of: activeChat),
              index > 0 else { return }
        
        let previousChat = chats[index - 1]
        selections = [previousChat]
    }
    
    // MARK: - Search
    var searchText: String = ""
    var localSearchText: String = ""
    var searchTokens = [ChatSearchToken]()
    
    var filteredTokens: [ChatSearchToken] {
        if searchTokens.isEmpty {
            return localSearchText.isEmpty
                ? ChatSearchToken.allCases
                : ChatSearchToken.allCases.filter { $0.name.lowercased().hasPrefix(localSearchText.lowercased()) }
        } else {
            return [] // Return an empty array if a token is already selected
        }
    }
    
    // MARK: - Quick Panel
    var isQuickPanelPresented: Bool = false
}
