//
//  ChatDetailMobile.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/01/2025.
//

import SwiftUI
import TipKit

struct ChatDetailMobile: View {
    @Environment(ChatVM.self) var chatVM
    
    @Bindable var chat: Chat
    
    @Namespace private var transition

    @State private var isFocused: Bool = false
    @State private var showingInspector: Bool = false
    @State private var searchScope: SearchScope = .regular
    @State private var showingExpandedSearch: Bool = false
    @State private var showCamera: Bool = false

    @AppStorage("focusChatOnAppear") var focusChatOnAppear: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(chat.currentThread, id: \.self) { group in
                    MessageView(group: group)
                        .environment(\.chat, chat)
                    #if !os(macOS)
                        .padding(.vertical, 2)
                    #endif
                }
                .listRowSeparator(.hidden)
                
                ErrorMessageView(chat: chat)
                
                Color.clear
                    .frame(height: chat.expandColor ? 400 : 1)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .id(String.bottomID)
            }
            .contentMargins([.top, .horizontal], 10)
            .environment(\.defaultMinListRowHeight, 1)
            .overlay {
                if chat.currentThread.isEmpty {
                    VStack {
                        Image(chat.config.model.imageName)
                            .font(.largeTitle)
                            .foregroundStyle(Color(hex: chat.config.model.color).gradient)
                            .symbolEffect(.rotate, options: .repeat(1), value: chat.config.model)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
//            .if(config.expandColor) {
//                $0.onScrollPhaseChange { oldPhase, newPhase in
//                    if newPhase == .interacting {
//                        withAnimation(.easeInOut(duration: 0.5)) {  config.expandColor = false }
//                    }
//                }
//            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaBar(edge: .bottom) {
                InputArea(chat: chat)
            }
            .navigationTitle(chat.config.model.name)
            .toolbarTitleMenu {
                ModelPicker(selectedModel: $chat.config.model)
            }
            .toolbarTitleDisplayMode(.inline)
            .listStyle(.plain)
            .task { onAppearStuff(proxy: proxy) }
            .onChange(of: isFocused) {
                if isFocused { Scroller.scrollToBottom(with: proxy, delay: 0.2) }
            }
            .onChange(of: chat.inputManager.state) {
                if chat.inputManager.state == .editing {
                    isFocused = true
                }
            }
            .searchable(text: $chat.inputManager.prompt, isPresented: $isFocused, prompt: "Ask Anything...")
            .searchPresentationToolbarBehavior(.avoidHidingContent)
//            .searchScopes($searchScope) {
//                Text("Regular").tag(SearchScope.regular)
//                Text("Expanded").tag(SearchScope.expanded)
//            }
//            .onChange(of: searchScope) {
//                if searchScope == .expanded {
//                    showingExpandedSearch = true
//                }
//            }
            .onSubmit(of: .search) {
                sendInput()
            }
            .sheet(isPresented: $showingInspector) {
                ChatInspector(chat: chat)
                    .navigationTransition(.zoom(sourceID: "shortcuts-button", in: transition))
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $showingExpandedSearch) {
                ExpandedSearchView(chat: chat, isSearchFocused: $isFocused)
                    .onDisappear {
                        searchScope = .regular
                    }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingInspector.toggle()
                    } label: {
                        Label("Shortcuts", systemImage: "info")
                    }
                }
                .matchedTransitionSource(id: "shortcuts-button", in: transition)
                
                ToolbarItem(placement: .bottomBar) {
                    ChatInputMenu(chat: chat, showCamera: $showCamera)
                }
                
                ToolbarSpacer(.fixed, placement: .bottomBar)
                
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                
                ToolbarSpacer(.fixed, placement: .bottomBar)
                
                if chat.isReplying {
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
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(chat: chat, isPresented: $showCamera)
                    .ignoresSafeArea()
            }
        }
    }
    
    private func sendInput() {
        chat.expandColor = true
        isFocused = false
        Task {
            await chat.sendInput()
        }
    }
    
    func onAppearStuff(proxy: ScrollViewProxy) {
        chatVM.activeChat = chat
        chat.expandColor = false
        chat.scrollProxy = proxy
        Scroller.scrollToBottom(with: proxy, animated: false)
        let shouldFocus = focusChatOnAppear || chat.inputManager.pendingFocus
        chat.inputManager.pendingFocus = false
        if shouldFocus {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isFocused = true
                Scroller.scrollToBottom(with: proxy, animated: true, delay: 0.3)
            }
        }
    }
}

enum SearchScope: String, CaseIterable, Hashable {
    case regular = "Regular"
    case expanded = "Expanded"
}
