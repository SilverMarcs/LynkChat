//
//  ChatDetailMobile.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/01/2025.
//

import SwiftUI
import TipKit

struct ChatDetailMobile: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.modelContext) var modelContext
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Bindable var chat: Chat

    @State private var colorViewHeight: CGFloat = 0
    @State private var isFocused: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            content
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    InputArea(chat: chat)
                }
                .animation(.bouncy, value: chat.currentThread.isEmpty)
                .navigationTitle(horizontalSizeClass == .compact ? chat.config.model.name : chat.title)
                .toolbarTitleMenu {
//                    Section(chat.title) {
//                        Button("Tokens: \(String(format: "%.2fK", Double(chat.totalTokens) / 1000.0))") { }
//                    }
                    ModelPicker(selectedModel: $chat.config.model)
                }
                .toolbarTitleDisplayMode(.inline)
                .listStyle(.plain)
                .task {
                    onAppearStuff(proxy: proxy)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { _ in
                    Scroller.scrollToBottom(delay: 0.1)
                }
                .searchable(text: $chat.inputManager.prompt, isPresented: $isFocused, prompt: "Ask Anything")
//                .onSubmit(of: .search) {
//                    print("not")
//                    sendInput()
//                }
                .onReceive(NotificationCenter.default.publisher(for: UISearchTextField.textDidEndEditingNotification)) { notification in
                    sendInput()
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        ChatInputMenu(chat: chat)
                    }
                    
                    ToolbarSpacer(.fixed, placement: .bottomBar)
                    
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                    
                    if chat.isReplying {
                        ToolbarSpacer(.fixed, placement: .bottomBar)
                        
                        ToolbarItem(placement: .bottomBar) {
                            Button(role: .destructive) {
                                chat.stopStreaming()
                            } label: {
                                Image(systemName: "stop.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
                .toolbar(.hidden, for: .tabBar)
        }
    }
    
    private func sendInput() {
        isFocused = false
        Task { @MainActor in
            await chat.sendInput()
        }
    }
    
    @ViewBuilder
    var content: some View {
        if chat.currentThread.isEmpty {
            VStack {                
                Image(chat.config.model.imageName)
                    .font(.largeTitle)
                    .foregroundStyle(Color(hex: chat.config.model.color).gradient)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        } else {
            list
        }
    }
    
    var list: some View {
        List {
            TipView(ContextMenuTip())
                .frame(maxWidth: 300, alignment: .trailing)
            
            ForEach(chat.currentThread, id: \.self) { group in
                MessageView(group: group)
                    .environment(\.chat, chat)
            }
            .listRowSeparator(.hidden)
            
            ErrorMessageView(chat: chat)
            
            Color.clear
                .frame(height: 1)
                .modifier(AnimatingCellHeight(height: config.expandColor ? 400 : 1))
                .listRowSeparator(.hidden)
            
            Color.clear
                .frame(height: 1)
                .transaction { $0.animation = nil }
                .id(String.bottomID)
                .listRowSeparator(.hidden)
        }
        .contentMargins(.bottom, -40)
    }
    
    // Rest of the helper methods and computed properties
    func onAppearStuff(proxy: ScrollViewProxy) {
        AppConfig.shared.expandColor = false
        Scroller.scrollToBottom(animated: false)
        config.proxy = proxy
    }
}
