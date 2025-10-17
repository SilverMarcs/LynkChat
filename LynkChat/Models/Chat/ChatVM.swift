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
    var chatPath: NavigationPath = NavigationPath()
    
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
        #if os(macOS)
        self.selections = [newChat]
        #else
        self.chatPath.removeLast()
        self.chatPath.append(newChat)
        #endif
    }

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
        if !chatPath.isEmpty {
            chatPath.removeLast()
        }
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

    func createTemporaryChat() {
        let newChat = Chat()
        newChat.status = .temporary
        globalContainer.mainContext.insert(newChat)
        self.activeChat = newChat
    }

    // MARK: - Quick Panel
    var quickPanelChat: Chat?
    var isQuickPanelPresented: Bool = false

    func getOrCreateQuickPanelChat() -> Chat {
        // TODO: use generic model here
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
                existingChat.deleteAllMessages()
                existingChat.config.systemPrompt = ChatConfigDefaults().quickSystemPrompt
                
                let registry = ModelRegistry.shared
                let enabledModels = registry.getEnabledModels()
                if let modelInfo = enabledModels.first,
                   let provider = registry.getProvider(modelInfo.providerId) {
                    existingChat.config.primaryModel = ChatModel(providerId: provider.id, modelInfoId: modelInfo.id)
                }
                
                return existingChat
            } else {
                let newChat = Chat()
                newChat.statusId = statusId
                newChat.status = ChatStatus.quick
                newChat.config.systemPrompt = ChatConfigDefaults().quickSystemPrompt
                
                let registry = ModelRegistry.shared
                let enabledModels = registry.getEnabledModels()
                if let modelInfo = enabledModels.first,
                   let provider = registry.getProvider(modelInfo.providerId) {
                    newChat.config.primaryModel = ChatModel(providerId: provider.id, modelInfoId: modelInfo.id)
                }
                
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
            newChat.config.systemPrompt = ChatConfigDefaults().quickSystemPrompt
            modelContext.insert(newChat)  // Insert into SwiftData
            quickPanelChat = newChat
            return newChat
        }
    }

    func clearQuickPanelChat() {
        quickPanelChat = nil
    }
}
