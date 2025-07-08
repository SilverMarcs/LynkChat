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
    
    @State private var numberOfMessagesToShow = 2
    
    var body: some View {
        ScrollViewReader { proxy in
            content
                .navigationTitle(horizontalSizeClass == .compact ? chat.config.model.name : chat.title)
                .navigationSubtitle("Tokens: \(String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))")
                .task {
                    onAppearStuff(proxy: proxy)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        AppConfig.shared.expandColor = false
                    }
                }
        }
    }
    
    @ViewBuilder
    var content: some View {
        if chat.currentThread.isEmpty {
            EmptyChat(chat: chat)
                .transition(.opacity)
        } else {
            list
        }
    }
    
    var list: some View {
        ScrollView {
            ForEach(chat.currentThread, id: \.self) { group in
                TipView(ContextMenuTip())
                    .frame(maxWidth: 300, alignment: .trailing)
                
                MessageView(group: group)
                    .environment(\.chat, chat)
                    .environment(\.searchText, chatVM.searchText)
//                    .onAppear {
//                        if group == messagesToShow.first {
//                            loadMoreMessages()
//                        }
//                    }
            }
            .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
            .listRowSeparator(.hidden)
            
            ErrorMessageView(chat: chat)
            
            Color.clear
                .frame(height: 1)
                .modifier(AnimatingCellHeight(height: spacerHeight))
                .listRowSeparator(.hidden)
                
            Color.clear
                .frame(height: 1)
                .transaction { $0.animation = nil }
                .id(String.bottomID)
                .listRowSeparator(.hidden)
        }
        .contentMargins(.all, 15, for: .scrollContent)
        .defaultScrollAnchor(.bottom)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if chat.status != .quick {
                InputArea(chat: chat)
            }
        }
    }
    
    var spacerHeight: CGFloat {
        if config.expandColor {
            return chat.status == .quick ? 250 : 475
        } else {
            return 1
        }
    }
    
    // Rest of the helper methods and computed properties
    func onAppearStuff(proxy: ScrollViewProxy) {
        AppConfig.shared.expandColor = false
        config.proxy = proxy
        
//        if chatVM.searchText.isEmpty {
//            Scroller.scrollToBottom(animated: false)
//        }
//        else {
//            numberOfMessagesToShow = chat.currentThread.count
//        }
    }
    
//    var messagesToShow: [MessageGroup] {
//        let totalMessages = chat.currentThread.count
//        if numberOfMessagesToShow >= totalMessages {
//            return chat.currentThread
//        } else {
//            return Array(chat.currentThread.suffix(numberOfMessagesToShow))
//        }
//    }
//    
//    private func loadMoreMessages() {
//        let totalMessages = chat.currentThread.count
//        if numberOfMessagesToShow <= totalMessages {
//            numberOfMessagesToShow += 2
//        }
//    }
}
