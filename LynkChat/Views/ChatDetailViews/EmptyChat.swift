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
    @Environment(ChatVM.self) private var chatVM
    
    @Bindable var chat: Chat
    @Query(filter: #Predicate<Chat> { chat in
        chat.statusId == 1 || chat.statusId == 2
    }, sort: \Chat.date, order: .reverse)
    var chats: [Chat]
    
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
//                .padding(.bottom, 5)
            
            VStack(alignment: .center) {
                InputArea(chat: chat)
                    .multilineTextAlignment(.leading)
                    .scaleEffect(1.05)
                
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
                        ForEach(chats.dropFirst().prefix(4)) { chat in
                            Button {
                                chatVM.selections = [chat]
                            } label: {
                                Label {
                                    Text(chat.title)
                                } icon: {
                                    Image(chat.config.model.imageName)
                                        .foregroundStyle(Color(hex: chat.config.model.color))
                                }
                                .frame(maxWidth: 175)
                                .frame(height: 20)
                                .padding(4)
                                .padding(.horizontal, 1)
                                .background(.quinary, in: .rect(cornerRadius: 9, style: .circular))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .frame(maxWidth: 750)
            .padding(.horizontal, 90)
            .padding(.bottom, 80)
            
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
