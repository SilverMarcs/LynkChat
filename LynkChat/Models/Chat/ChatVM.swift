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
    @discardableResult
    func createNewChat(model: ChatModel? = nil) -> Chat {
        let newChat = Chat()
        
        if let model = model {
            newChat.config.model = model
        }
        
        DatabaseService.shared.modelContext.insert(newChat)
        self.activeChat = newChat
        return newChat
    }
    
    @MainActor
    func createTemporaryChat() {
        let newChat = Chat()
        newChat.status = .temporary
        DatabaseService.shared.modelContext.insert(newChat)
        self.activeChat = newChat
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
