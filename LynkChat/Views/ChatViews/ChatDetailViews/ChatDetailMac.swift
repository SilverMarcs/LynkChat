//
//  ChatDetailMac.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/01/2025.
//

import SwiftUI

struct ChatDetailMac: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.modelContext) var modelContext
    var chat: Chat
    
    @Namespace var inputNS
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(chat.currentThread, id: \.self) { group in
                        MessageView(group: group)
                            .environment(\.chat, chat)
                    }
                    
                    ErrorMessageView(chat: chat)
                    
                    Color.clear
                        .frame(height: chat.expandColor
                               ? (chat.status == .quick ? 250 : 475)
                               : 1)
                        .id(String.bottomID)
                }
            }
            .overlay(alignment: .center) {
                if chat.isEmpty {
                    EmptyChat(chat: chat, namespace: inputNS)
                }
            }
            .contentMargins(.all, 15, for: .scrollContent)
            .navigationTitle(horizontalSizeClass == .compact ? chat.config.model.name : chat.title)
            .navigationSubtitle(chat.config.systemPrompt.prefix(100))
            .task {
                chat.expandColor = false
                chat.scrollProxy = proxy
                proxy.scrollTo(String.bottomID, anchor: .bottom)
            }
            .onDisappear {
                if chat.status == .temporary {
                    modelContext.delete(chat)
                }
            }
            .toolbar {
                ChatToolbar(chat: chat)
            }
            .safeAreaBar(edge: .bottom) {
                if !chat.isEmpty && chat.status != .quick {
                    InputArea(chat: chat)
                        .matchedGeometryEffect(id: "input", in: inputNS)
                }
            }
//            .onScrollPhaseChange { oldPhase, newPhase in
//                if newPhase == .interacting {
//                    withAnimation(.easeInOut(duration: 0.5)) {
//                        config.expandColor = false
//                    }
//                }
//                return
//            }
        }
    }
}
