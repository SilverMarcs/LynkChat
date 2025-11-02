//
//  EmptyChat.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/09/2024.
//

import SwiftUI
import SwiftData
import TipKit

struct EmptyChat: View {
    @Bindable var chat: Chat
    @Environment(ChatVM.self) var chatVM
    @Query(filter: #Predicate<Chat> { chat in
        chat.statusId == 1 || chat.statusId == 2
    }, sort: \Chat.date, order: .reverse)
    var chats: [Chat]
    
    var namespace: Namespace.ID
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("AppIconPng")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 75, height: 75)
                .opacity(0.9)
            
            Text("Start a conversation")
                .font(.system(size: 25, weight: .semibold))
                .fontWeight(.bold)
                .opacity(0.9)
            
            VStack {
                InputArea(chat: chat)
                    .matchedGeometryEffect(id: "input", in: namespace)
                    .multilineTextAlignment(.leading)
                
                TipView(PlusButtonTip())
                    .fixedSize()
                
                if chat.status == .temporary {
                    HStack {
                        Image(systemName: "gauge.with.needle")
                        
                        Text("TEMPORARY CHAT")
                            .fontWidth(.condensed)
                    }
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(.tertiary)
                    
                } else {
                    HStack(alignment: .center) {
                        ForEach(chats.dropFirst().prefix(3)) { chat in
                            Button {
                                chatVM.selections = [chat]
                            } label: {
                                Label {
                                    Text(chat.title)
                                } icon: {
                                    Image(chat.config.model.imageName)
                                        .foregroundStyle(Color(hex: chat.config.model.color))
                                }
                                .frame(maxWidth: 185)
                                .frame(height: 20)
                            }
                            .buttonStyle(.glass)
                            .buttonBorderShape(.capsule)
                        }
                    }
                }
            }
            .frame(maxWidth: 750)
            .padding(.horizontal, 90)
            
            Spacer(minLength: 1)
            
            Text("AI Can make mistakes. Verify important information.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding()
        }
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    EmptyChat(chat: .mockChat)
//}
