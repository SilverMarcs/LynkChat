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
    var chatPath: NavigationPath = NavigationPath()
//    var imageSelection: ImageSession?
    
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
//        self.selections = []
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.selections = [newChat]
//        }
        self.chatPath.removeLast()
        self.chatPath.append(newChat)
        #endif
    }

    @MainActor
    @discardableResult
    func createNewChat(model: ChatModel? = nil, delay: Bool = false) -> Chat {
        let newChat = Chat()

        if let model = model {
            newChat.config.model = model
        }

        globalContainer.mainContext.insert(newChat)
        #if os(macOS)
        self.activeChat = newChat
        selections = [newChat]
        #else
        if delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.chatPath.append(newChat)
            }
        } else {
            chatPath.append(newChat)
        }
        #endif
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
    var quickPanelChat: Chat?
    var isQuickPanelPresented: Bool = false

    @MainActor
    func getOrCreateQuickPanelChat() -> Chat {
        if let existingChat = quickPanelChat {
            return existingChat
        }

        let statusId = ChatStatus.quick.id
        var descriptor = FetchDescriptor<Chat>(
            predicate: #Predicate { $0.statusId == statusId }
        )
        descriptor.fetchLimit = 1
        
        let modelContext = globalContainer.mainContext

        do {
            let quickChats = try modelContext.fetch(descriptor)
            if let existingChat = quickChats.first {
                existingChat.deleteAllMessages() // Clear existing messages
                existingChat.config.model = ChatModel.small_model
                return existingChat
            } else {
                let newChat = Chat()
                newChat.statusId = statusId
                newChat.status = ChatStatus.quick
                newChat.config.systemPrompt = ChatConfigDefaults.shared.quickSystemPrompt
                modelContext.insert(newChat)
                quickPanelChat = newChat
                return newChat
            }
        } catch {
            print("Error fetching or creating quick panel chat: \(error)")
            // Handle the error appropriately (e.g., show an alert)
            // For now, return a new chat to prevent the app from crashing
            // ideally, this should never happen
            let newChat = Chat()
            newChat.statusId = ChatStatus.quick.id
            newChat.status = ChatStatus.quick
            newChat.config.systemPrompt = ChatConfigDefaults.shared.quickSystemPrompt
            modelContext.insert(newChat)  // Insert into SwiftData
            quickPanelChat = newChat
            return newChat
        }
    }

    func clearQuickPanelChat() {
        quickPanelChat = nil
    }
}
