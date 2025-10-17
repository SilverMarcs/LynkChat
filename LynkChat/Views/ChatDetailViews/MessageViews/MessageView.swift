//
//  MessageView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct MessageView: View {
    @Environment(\.chat) var chat
    var group: MessageGroup
    
    var body: some View {
        Group {
            switch group.role {
            case .user:
                UserMessage(group: group)
            case .assistant:
                AssistantMessageAux(group: group)
            }
            
            if chat.contextResetPoint == group {
                ContextResetDivider() { chat.resetContext(at: group)}
                    .padding(.vertical)
            }
        }
        #if os(iOS)
        .opacity(0.9)
        #endif
    }
}
