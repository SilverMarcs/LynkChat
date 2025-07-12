//
//  ChatDetailMac.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/01/2025.
//

import SwiftUI
import TipKit

struct ChatDetailMac: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.modelContext) var modelContext
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Bindable var chat: Chat
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(chat.currentThread, id: \.self) { group in
                    
                    MessageView(group: group)
                        .environment(\.chat, chat)
                        .environment(\.searchText, chatVM.searchText)
                }
                
                ErrorMessageView(chat: chat)
                
                Color.clear
                    .frame(height: 1)
                    .modifier(
                        AnimatingCellHeight(height: config.expandColor
                                ? (chat.status == .quick ? 250 : 475)
                                : 1
                        )
                    )

                    
                Color.clear
                    .frame(height: 1)
                    .transaction { $0.animation = nil }
                    .id(String.bottomID)
            }
            .overlay {
                if chat.currentThread.isEmpty {
                    EmptyChat(chat: chat)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .contentMargins(.all, 15, for: .scrollContent)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if chat.status != .quick, !chat.currentThread.isEmpty {
                    InputArea(chat: chat)
                }
            }
            .navigationTitle(horizontalSizeClass == .compact ? chat.config.model.name : chat.title)
            .navigationSubtitle("Tokens: \(String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))")
            .task {
                onAppearStuff(proxy: proxy)
            }
            .onScrollPhaseChange { oldPhase, newPhase in
                if newPhase == .interacting {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        config.expandColor = false
                    }
                }
                return
            }
        }
    }
    
    // Rest of the helper methods and computed properties
    func onAppearStuff(proxy: ScrollViewProxy) {
        config.expandColor = false
        config.proxy = proxy
        
        if chatVM.searchText.isEmpty {
            Scroller.scrollToBottom(animated: false)
        }
    }
}
