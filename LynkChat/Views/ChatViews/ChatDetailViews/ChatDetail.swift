//
//  ChatDetail.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import TipKit

struct ChatDetail: View {
    var chat: Chat
    
    var body: some View {
        Group {
            #if os(macOS)
            ChatDetailMac(chat: chat)
            #else
            ChatDetailMobile(chat: chat)
            #endif
        }
        .id(chat.id)
        // TODO: fix this
        .onDrop(of: [.item], isTargeted: nil) { providers in
            do {
                return try chat.inputManager.handleDrop(providers)
            } catch {
                chat.errorMessage = error.localizedDescription
                return false
            }
        }
    }
}
