//
//  EmptyChat.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/09/2024.
//

import SwiftUI

struct EmptyChat: View {
    @Bindable var chat: Chat
    
    var body: some View {
        VStack {
            Image(chat.config.provider.type.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.quaternary)
            
            if chat.status == .temporary {
                Text("Temporary Chat")
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(.tertiary)
                
                Text("Click button on top right of window to save this chat")
                    .font(.body)
                    .foregroundStyle(.tertiary)
            }
        }
        .multilineTextAlignment(.center)
        .fullScreenBackground()
    }
}

#Preview {
    EmptyChat(chat: .mockChat)
}
