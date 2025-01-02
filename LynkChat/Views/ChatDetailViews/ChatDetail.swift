//
//  ChatDetail.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import TipKit

struct ChatDetail: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.modelContext) var modelContext
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Bindable var chat: Chat
    
    @State private var numberOfMessagesToShow = 2
    @State private var colorViewHeight: CGFloat = 0 // Initial height
    
    @Namespace private var inputTransition
    
    var body: some View {
        ScrollViewReader { proxy in
            content
                .animation(.default, value: chat.currentThread.isEmpty)
            .toolbar {
                ChatToolbar(chat: chat)
            }
            .onDrop(of: Array(chat.config.model.supportedTypes), isTargeted: nil) { providers in
                do {
                   return try chat.inputManager.handleDrop(providers)
                } catch {
                    chat.errorMessage = error.localizedDescription
                    return false
                }
            }
            .navigationTitle(horizontalSizeClass == .compact ? chat.config.model.name : chat.title)
            .toolbarTitleMenu {
                Section(chat.title) {
                    Button("Tokens: \(String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))") { }
                }
            }
            .toolbarTitleDisplayMode(.inline)
//            .onChange(of: chat.inputManager.prompt) {
//                if chat.inputManager.state == .normal {
//                    Scroller.scrollToBottom(animated: false)
//                }
//            }
//            .onChange(of: chat.inputManager.dataFiles) {
//                if chat.inputManager.state == .normal {
//                    Scroller.scrollToBottom(animated: false)
//                }
//            }
            #if os(macOS)
            .onAppear {
                if chatVM.searchText.isEmpty {
                    Scroller.scrollToBottom(animated: false)
                }
                onAppearStuff(proxy: proxy)
            }
            .navigationSubtitle("\(chat.config.model.name) • \(chat.config.systemPrompt.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines).prefix(69))")
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                config.hasUserScrolled = true
            }
            #else
            .task {
//                scrollToBottom(proxy: proxy, delay: 0.3)
                Scroller.scrollToBottom(delay: 0.3)
                onAppearStuff(proxy: proxy)
            }
            .listStyle(.plain)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { _ in
                    Scroller.scrollToBottom(delay: 0.1)
            }
            #if !os(visionOS)
            .scrollDismissesKeyboard(.immediately)
            #endif
            #endif
        }
    }
    
    func onAppearStuff(proxy: ScrollViewProxy) {
        config.hasUserScrolled = false
        config.proxy = proxy
        
        if !chatVM.searchText.isEmpty {
            numberOfMessagesToShow = chat.currentThread.count
        }
        
        if chatVM.searchText.isEmpty {
            #if os(macOS)
            Scroller.scrollToBottom(animated: false)
            #else
            Scroller.scrollToBottom(delay: 0.3)
            #endif
        }
    }
    
    var messagesToShow: [MessageGroup] {
        let totalMessages = chat.currentThread.count
        if numberOfMessagesToShow >= totalMessages {
            return chat.currentThread
        } else {
            return Array(chat.currentThread.suffix(numberOfMessagesToShow))
        }
    }
    
    @ViewBuilder
    var content: some View {
        #if os(macOS) || os(visionOS)
        if chat.currentThread.isEmpty {
            EmptyChat(chat: chat, namespace: inputTransition)
                .transition(.opacity)
        } else {
            list
        }
        #else
        list
        #endif
    }
    
    var list: some View {
        List {
            ForEach(messagesToShow, id: \.self) { group in
                MessageView(group: group)
                    .environment(\.chat, chat)
                    .onAppear {
                        if group == messagesToShow.first {
                            loadMoreMessages()
                        }
                    }
            }
            #if os(macOS)
            .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
            #endif
            .listRowSeparator(.hidden)
            
            ErrorMessageView(chat: chat)
            
            if chat.status != .quick {
                resizingColor
            }
            
            Color.clear
                #if os(macOS)
                .listRowInsets(.init(top: -5, leading: 0, bottom: -5, trailing: 0))
                #endif
                .frame(height: 1)
                .transaction { $0.animation = nil }
                .id(String.bottomID)
                .listRowSeparator(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if chat.status != .quick {
                InputArea(chat: chat)
                    #if os(macOS)
                    .roundedRectangleOverlay(radius: 15, opacity: 0.6, style: .circular)
                    .modifier(CommonInputStyling())
                    #endif
                    .matchedGeometryEffect(id: "inputArea", in: inputTransition)
            }
        }
        .transition(.opacity)
    }
    
    private func loadMoreMessages() {
        let totalMessages = chat.currentThread.count
        if numberOfMessagesToShow <= totalMessages {
            numberOfMessagesToShow += 2
        }
    }
    
    @State var change: Bool = false
    
    var resizingColor: some View {
        Color.clear
//            .frame(height: colorViewHeight)
//            .frame(width: 200)
            .frame(height: 1)
             .modifier(AnimatingCellHeight(height: change ? 475 : 1))
            #if os(macOS)
            .listRowInsets(.init(top: -5, leading: 0, bottom: -5, trailing: 0))
            #endif
            .listRowSeparator(.hidden)
            .onChange(of: chat.isReplying) {
                if chat.isReplying {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        change = true
                    } completion: {
                        Scroller.scrollToBottom()
                    }
                }
            }
            .onChange(of: config.hasUserScrolled) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    change = false
                }
        }
    }
}

#Preview {
    ChatDetail(chat: .mockChat)
        .environment(ChatVM.mockChatVM)
}
