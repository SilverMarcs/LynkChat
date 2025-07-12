//
//  ChatDetailMobile.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/01/2025.
//

import SwiftUI
import TipKit

struct ChatDetailMobile: View {
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Bindable var chat: Chat

    @State private var colorViewHeight: CGFloat = 0
    @State private var isFocused: Bool = false
    
    private let chatVM = ChatVM.shared
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(chat.currentThread, id: \.self) { group in
                    MessageView(group: group)
                        .environment(\.chat, chat)
                }
                .listRowSeparator(.hidden)
                
                ErrorMessageView(chat: chat)
                
                Color.clear
                    .frame(height: 1)
                    .modifier(AnimatingCellHeight(height: config.expandColor ? 375 : 1))
                    .listRowSeparator(.hidden)
                
                Color.clear
                    .frame(height: 1)
                    .transaction { $0.animation = nil }
                    .id(String.bottomID)
                    .listRowSeparator(.hidden)
            }
            .overlay {
                if chat.currentThread.isEmpty {
                    VStack {
                         Image(chat.config.model.imageName)
                             .font(.largeTitle)
                             .foregroundStyle(Color(hex: chat.config.model.color).gradient)
                     }
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                     .padding()
                }
            }
            .onScrollPhaseChange { oldPhase, newPhase in
                if newPhase == .interacting {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        config.expandColor = false
                    }
                }
                return
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                InputArea(chat: chat)
            }
            .navigationTitle(chat.config.model.name)
            .toolbarTitleMenu {
                ModelPicker(selectedModel: $chat.config.model)
            }
            .toolbarTitleDisplayMode(.inline)
            .listStyle(.plain)
            .task {
                onAppearStuff(proxy: proxy)
            }
            .onChange(of: isFocused) {
                if isFocused {
                    Scroller.scrollToBottom(delay: 0.2)
                }
            }
            .searchable(text: $chat.inputManager.prompt, isPresented: $isFocused, prompt: "Ask Anything")
//            .onSubmit(of: .search) {
//                sendInput()
//            }
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
    
    // Rest of the helper methods and computed properties
    func onAppearStuff(proxy: ScrollViewProxy) {
        config.expandColor = false
        config.proxy = proxy
        Scroller.scrollToBottom(animated: false)
    }
}
