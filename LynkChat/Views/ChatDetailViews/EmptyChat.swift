//
//  EmptyChat.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/09/2024.
//

import SwiftUI
import TipKit

struct EmptyChat: View {
    @Bindable var chat: Chat
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Start a conversation")
                .font(.system(size: 25, weight: .semibold))
                .fontWeight(.bold)
                .opacity(0.9)
                .padding(.bottom, 15)
            
            InputArea(chat: chat)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 750)
                .scaleEffect(1.05)
                .padding(.horizontal, 90)
            
            TipView(PlusButtonTip())
                .fixedSize()
            
            if chat.status == .temporary {
                VStack {
                    Text("Temporary Chat")
                        .font(.title2).fontWeight(.bold)
                        .foregroundStyle(.tertiary)
                    
                    Text("Click button on top right of window to save this chat")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            Text("AI Can make mistakes. Verify important information.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding()
        }
        .toolbarBackground(.hidden)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    @Previewable @Namespace var inputTransition
    
    EmptyChat(chat: .mockChat)
        .environment(ChatVM())
}
