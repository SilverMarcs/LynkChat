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
        let modelContext = globalContainer.mainContext
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
        let predicate = #Predicate<Chat> { chat in
            chat.rootMessage == nil && (chat.statusId == 1 || chat.statusId == 2)
        }
        
        var descriptor = FetchDescriptor<Chat>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        descriptor.fetchLimit = 1
        
        if let existingEmptyChat = try? globalContainer.mainContext.fetch(descriptor).first {
            if let model = model {
                existingEmptyChat.config.model = model
            }
            selections = [existingEmptyChat]
            self.activeChat = existingEmptyChat
            return existingEmptyChat
        }
        
        let newChat = Chat()
        
        if let model = model {
            newChat.config.model = model
        }
        
        globalContainer.mainContext.insert(newChat)
        self.activeChat = newChat
        return newChat
    }
    
    @MainActor
    func createTemporaryChat() {
        let newChat = Chat()
        newChat.status = .temporary
        globalContainer.mainContext.insert(newChat)
        self.activeChat = newChat
    }
    
    // MARK: - Search
    var searchText: String = ""
    var localSearchText: String = ""
    
    // MARK: - Quick Panel
    var isQuickPanelPresented: Bool = false
}
