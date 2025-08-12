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
    var config: AppSettings = AppSettings.shared
    
    var chat: Chat
    @State private var showAllMessages = false
    
    private var visibleMessages: [MessageGroup] {
        if showAllMessages {
            return chat.currentThread
        } else {
            return []
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(visibleMessages, id: \.self) { group in
                        MessageView(group: group)
                            .environment(\.chat, chat)
                    }
                    
                    ErrorMessageView(chat: chat)
                    
                    Color.clear
                        .frame(height: config.expandColor
                               ? (chat.status == .quick ? 250 : 475)
                               : 1)
                        .id(String.bottomID)
                }
                .overlay(alignment: .center) {
                    if chat.currentThread.isEmpty {
                        EmptyChat(chat: chat)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !showAllMessages {
                        ProgressView()
                    }
                }
            }
            .contentMargins(.all, 15, for: .scrollContent)
            .navigationTitle(horizontalSizeClass == .compact ? chat.config.model.name : chat.title)
            .navigationSubtitle(unsafe "Tokens: \(String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))")
            .task {
                onAppearStuff(proxy: proxy)
            }
            .safeAreaBar(edge: .bottom, spacing: 0) {
                if chat.status != .quick, !chat.currentThread.isEmpty {
                    InputArea(chat: chat)
                }
            }
//            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
//                withAnimation(.easeInOut(duration: 0.5)) {
//                    config.expandColor = false
//                }
//              }
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
    
    func onAppearStuff(proxy: ScrollViewProxy) {
        config.expandColor = false
        config.proxy = proxy
        showAllMessages = true
        Scroller.scrollToBottom(animated: false)
    }
}
