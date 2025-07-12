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
    
    var body: some ToolbarContent {
        ToolbarSpacer()
        
//#if os(macOS)
//        ToolbarItem(placement: .keyboard) {
//            Button(action: {
//                // Get the indices of the selected chats
//                let indices = chatVM.selections.compactMap { chat in
//                    chats.firstIndex(of: chat)
//                }
//                // Create an IndexSet from the indices
//                let indexSet = IndexSet(indices)
//                // Perform the delete operation
//                deleteItems(indexSet)
//            }) {
//                Image(systemName: "trash")
//            }
//            .keyboardShortcut(.delete, modifiers: [.command])
//            .disabled(chatVM.selections.count <= 0)
//        }
//#endif
        
        ToolbarSpacer(placement: .primaryAction)
        
        ToolbarItem(placement: .primaryAction) {
            Menu {
                ForEach(ChatModel.allCases) { model in
                    Button {
                        ChatVM.shared.createNewChat(model: model)
                    } label: {
                        Label(model.name, image: model.imageName)
                            .labelStyle(.titleAndIcon)
                    }
                }
            } label: {
                Label("New Chat", systemImage: "square.and.pencil")
            } primaryAction: {
                ChatVM.shared.createNewChat()
            }
            .menuIndicator(.hidden)
            .popoverTip(NewChatTip())
        }
    }
}
