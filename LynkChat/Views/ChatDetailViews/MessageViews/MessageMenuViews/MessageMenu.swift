//
//  MessageMenu.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct MessageMenu: View {
    @Environment(\.chat) var chat
    @Bindable var group: MessageGroup
    var toggleTextSelection: (() -> Void)? = nil

    var body: some View {
        Section {
            if !group.isSplitView {
                RegenButton {
                    await chat.regenerate(message: group)
                }
            }
            
            if group.role == .user {
                EditButton(setupEditing: { chat.inputManager.setupEditing(message: group) })
            }
        }
        
        Section {
            CopyButton(content: group.content, dataFiles: group.dataFiles)
        }

        Section {
//            #if !os(macOS)
            if let toggleTextSelection = toggleTextSelection {
                SelectTextButton(toggleTextSelection: toggleTextSelection)
            }
//            #endif
            
            ForkButton(copyChat: { await chat.copy(from: group.activeMessage) })
        }
        
        Section {
            ResetContextButton(resetContext: { chat.resetContext(at: group) })
            
            if chat.currentThread.last == group {
                DeleteButton(deleteLastMessage: {
                    chat.deleteLastMessage()
                    chat.errorMessage = ""
                })
            }
        }
    }
}

#Preview {
    VStack {
        MessageMenu(group: .mockUserGroup)
        MessageMenu(group: .mockAssistantGroup)
    }
    .frame(width: 500)
    .padding()
}
