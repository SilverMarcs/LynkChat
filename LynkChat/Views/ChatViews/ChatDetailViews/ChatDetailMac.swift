//
//  ChatDetailMac.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/01/2025.
//

import SwiftUI

struct ChatDetailMac: View {
    @Environment(ChatVM.self) var chatVM
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.modelContext) var modelContext
    var chat: Chat
    
    @Namespace var inputNS
    @State private var isPreparingInitialScroll = true
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(chat.currentThread, id: \.self) { group in
                    MessageView(group: group)
                        .environment(\.chat, chat)
                        .listRowSeparator(.hidden)
                }
                
                ErrorMessageView(chat: chat)
                .listRowSeparator(.hidden)
                
                Color.clear
                    .frame(height: chat.expandColor
                           ? (chat.status == .quick ? 250 : 475)
                           : 1)
                    .id(String.bottomID)
                    .listRowSeparator(.hidden)
            }
            .overlay(alignment: .center) {
                if chat.isEmpty {
                    EmptyChat(chat: chat, namespace: inputNS)
                }
            }
            .overlay {
                if isPreparingInitialScroll && !chat.isEmpty {
                    ZStack {
                        Rectangle().fill(.background)
                        ProgressView().controlSize(.large)
                    }
                    .ignoresSafeArea()
                }
            }
            .navigationTitle(horizontalSizeClass == .compact ? chat.config.model.name : chat.title)
            .navigationSubtitle(chat.config.systemPrompt.prefix(100))
            .task(id: chat.id) {
                isPreparingInitialScroll = true
                chat.expandColor = false
                chat.scrollProxy = proxy
                try? await Task.sleep(for: .milliseconds(50))
                Scroller.scrollToBottom(with: proxy, animated: false)
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else { return }
                isPreparingInitialScroll = false
            }
            .onDisappear {
                if chat.status == .temporary {
                    modelContext.delete(chat)
                }
            }
            .toolbar {
                ChatToolbar(chat: chat)
            }
            .focusedSceneValue(\.activeChat, chat)
            .safeAreaBar(edge: .bottom) {
                if !chat.isEmpty && chat.status != .quick {
                    InputArea(chat: chat)
                    .id(chat.id)
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
