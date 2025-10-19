//
//  ChatListToolbar.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/07/2025.
//

import SwiftUI

struct ChatListToolbar: ToolbarContent {
    let chats: [Chat]
    let deleteItems: (IndexSet) -> Void
    @Environment(ChatVM.self) var chatVM
    @Environment(ModelRegistry.self) var registry
    
    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .keyboard) {
            Button(action: {
                let indices = chatVM.selections.compactMap { chat in
                    chats.firstIndex(of: chat)
                }
                let indexSet = IndexSet(indices)
                deleteItems(indexSet)
            }) {
                Image(systemName: "trash")
            }
            .keyboardShortcut(.delete, modifiers: [.command, .shift])
            .disabled(chatVM.selections.count <= 0)
        }
        #endif
        
         ToolbarItem {
             Menu {
                 ForEach(registry.getEnabledModels(), id: \.id) { modelInfo in
                     Button {
                         chatVM.createNewChat(model: modelInfo)
                     } label: {
                         Label(modelInfo.name, image: modelInfo.theme.imageName)
                             .labelStyle(.titleAndIcon)
                     }
                 }
             } label: {
                 Label("New Chat", systemImage: "square.and.pencil")
             } primaryAction: {
                 chatVM.createNewChat()
             }
             .menuIndicator(.hidden)
         }
    }
}
