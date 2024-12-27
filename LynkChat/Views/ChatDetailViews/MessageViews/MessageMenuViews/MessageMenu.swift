//
//  MessageMenu.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct MessageMenu: View {
    @Bindable var message: MessageGroup
    var toggleTextSelection: (() -> Void)? = nil

    var body: some View {
        Section {
            if !message.isSplitView {
                 RegenButton(group: message)
            }
            
            if message.role == .user {
                EditButton(setupEditing: { message.chat?.inputManager.setupEditing(message: message) })
            }
        }
        
        Section {
            CopyButton(content: message.content, dataFiles: message.dataFiles)
        }

        Section {
            #if !os(macOS)
            if let toggleTextSelection = toggleTextSelection {
                SelectTextButton(toggleTextSelection: toggleTextSelection)
            }
            #endif
            
            ForkButton(copyChat: { await message.chat?.copy(from: message.activeMessage) })
        }
        
        Section {
            ResetContextButton(resetContext: { message.chat?.resetContext(at: message) })
            
            if message.chat?.currentThread.last == message {
                DeleteButton(deleteLastMessage: {
                    message.chat?.deleteLastMessage()
                    message.chat?.errorMessage = ""
                })
            }
        }
    }
}

#Preview {
    VStack {
        MessageMenu(message: .mockUserGroup)
        MessageMenu(message: .mockAssistantGroup)
    }
    .frame(width: 500)
    .padding()
}
