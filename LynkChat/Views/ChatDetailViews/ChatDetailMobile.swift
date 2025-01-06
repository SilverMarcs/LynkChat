//
//  ChatDetailMobile.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/01/2025.
//

import SwiftUI

struct ChatDetailMobile: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.modelContext) var modelContext
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Bindable var chat: Chat

    @State private var colorViewHeight: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            content
                .animation(.bouncy, value: chat.currentThread.isEmpty)
                .navigationTitle(horizontalSizeClass == .compact ? chat.config.model.name : chat.title)
                .toolbarTitleMenu {
                    Section(chat.title) {
                        Button("Tokens: \(String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))") { }
                    }
                }
                .toolbarTitleDisplayMode(.inline)
                .listStyle(.plain)
                .task {
                    onAppearStuff(proxy: proxy)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { _ in
                    Scroller.scrollToBottom(delay: 0.1)
                }
        }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            if chat.currentThread.isEmpty {
                VStack {
                    Text("Start a conversation")
                        .font(.title)
                    
                    HStack(spacing: 15) {
                        ToolsBarView(config: $chat.config)
                            .scaleEffect(1.4)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            list
            
            Spacer()
        }
        .padding(.bottom, 0)
        .scrollDismissesKeyboard(.immediately)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            InputArea(chat: chat)
        }
    }
    
    var list: some View {
        List {
            ForEach(chat.currentThread, id: \.self) { group in
                MessageView(group: group)
                    .environment(\.chat, chat)
            }
            .listRowSeparator(.hidden)
            
            ErrorMessageView(chat: chat)
            
            if chat.status != .quick {
                resizingColor
            }
            
            Color.clear
                .frame(height: 1)
                .transaction { $0.animation = nil }
                .id(String.bottomID)
                .listRowSeparator(.hidden)
        }
    }
    
    // Rest of the helper methods and computed properties
    func onAppearStuff(proxy: ScrollViewProxy) {
        Scroller.scrollToBottom(delay: 0.3)
        config.proxy = proxy
        AppConfig.shared.expandColor = false
    }
    
    var resizingColor: some View {
        Color.clear
            .frame(height: 1)
            .modifier(AnimatingCellHeight(height: config.expandColor ? 400 : 1))
            .listRowSeparator(.hidden)
    }
}
