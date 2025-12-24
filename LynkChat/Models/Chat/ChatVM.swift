//
//  ChatVM.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@Observable class ChatVM {
    var selections: Set<Chat> = []
    var chatPath: [Chat] = []
    
    var statusFilter: ChatStatus = .normal
    
    var currentChat: Chat?
    var activeChat: Chat? {
        get {
            #if os(macOS)
            guard selections.count == 1 else { return nil }
            return selections.first
            #else
            return currentChat
            #endif
        }
        set {
            #if os(macOS)
            selections = newValue.map { [$0] } ?? []
            #else
            currentChat = newValue
            #endif
        }
    }

    func fork(newChat: Chat) {
        newChat.isEmpty = false
        let modelContext = globalContainer.mainContext
        modelContext.insert(newChat)
        selectChat(newChat)
    }

    @discardableResult
    func createNewChat(model: ChatModel? = nil, delay: Bool = false) -> Chat {
        let newChat = Chat()

        if let model = model {
            newChat.config.model = model
        }

        globalContainer.mainContext.insert(newChat)
        let delayDuration: Duration? = delay ? .milliseconds(500) : nil
        selectChat(newChat, delay: delayDuration)
        return newChat
    }

    func createTemporaryChat() {
        let newChat = Chat()
        newChat.status = .temporary
        globalContainer.mainContext.insert(newChat)
        self.activeChat = newChat
    }

    func selectChat(_ chat: Chat, delay: Duration? = nil) {
        #if os(macOS)
        activeChat = chat
        selections = [chat]
        #else
        currentChat = chat
        selections = [chat]

        if !chatPath.isEmpty {
            chatPath.removeLast()
        }

        if let delay {
            Task {
                try? await Task.sleep(for: delay)
                self.chatPath.append(chat)
            }
        } else {
            chatPath.append(chat)
        }
        #endif
    }

    // MARK: - Quick Panel
    var isQuickPanelPresented: Bool = false
    
    func getOrCreateQuickPanelChat() -> Chat {
        let statusId = ChatStatus.quick.id
        var descriptor = FetchDescriptor<Chat>(
            predicate: #Predicate { $0.statusId == statusId }
        )
        descriptor.fetchLimit = 1
        
        let modelContext = globalContainer.mainContext
        let defaults = ChatConfigDefaults()
        
        do {
            let quickChats = try modelContext.fetch(descriptor)
            if let existingChat = quickChats.first {
                existingChat.deleteAllMessages() // Clear existing messages
                existingChat.config.systemPrompt = defaults.quickSystemPrompt
                existingChat.config.models = [defaults.quickDefaultModel]
                
                return existingChat
            } else {
                let newChat = Chat()
                newChat.statusId = statusId
                newChat.status = ChatStatus.quick
                newChat.config.systemPrompt = defaults.quickSystemPrompt
                newChat.config.models = [defaults.quickDefaultModel]
                
                modelContext.insert(newChat)
                return newChat
            }
        } catch {
            fatalError("Error fetching or creating quick panel chat: \(error)")
        }
    }
}
