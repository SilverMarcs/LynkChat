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
    var namespace: Namespace.ID
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Start a conversation")
                .font(.system(size: 25, weight: .semibold))
                .fontWeight(.bold)
                .opacity(0.9)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .padding(.bottom, 15)
            
            InputArea(chat: chat)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 750)
                .background(.background.secondary, in: .rect(cornerRadius: 15))
                .roundedRectangleOverlay(radius: 15, style: .circular)
                .matchedGeometryEffect(id: "inputArea", in: namespace)
                .scaleEffect(1.05)
                .padding(.horizontal, 90)
            
            TipView(PlusButtonTip())
                .fixedSize()
//                .frame(height: 30)
            
            if chat.status == .temporary {
                VStack {
                    Text("Temporary Chat")
                        .font(.title2).fontWeight(.bold)
                        .foregroundStyle(.tertiary)
                    
                    Text("Click button on top right of window to save this chat")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            Spacer()
            
            Text("AI Can make mistakes. Verify important information.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding()
                .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
        .toolbarBackground(.hidden)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    @Previewable @Namespace var inputTransition
    
    EmptyChat(chat: .mockChat, namespace: inputTransition)
        .environment(ChatVM())
}
