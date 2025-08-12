//
//  ChatToolbar.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ChatToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat
    
    @State private var showingInspector: Bool = false
    @State private var currentSearchIndex: Int = 0
    @State private var showToolbarItems: Bool = false // Add this state
    
    @FocusState private var isFocused: FocusedField?
    
    private let chatVM = ChatVM.shared
    
    var body: some ToolbarContent {
        ToolbarItem(placement: horizontalSizeClass == .compact ? .primaryAction : .navigation) {
            Button(action: toggleInspector) {
                Label("Shortcuts", systemImage: horizontalSizeClass == .compact ? "info" : "slider.vertical.3")
            }
            .keyboardShortcut(".")
            .sheet(isPresented: $showingInspector) {
                ChatInspector(chat: chat)
                    .presentationDetents(horizontalSizeClass == .compact ? [.medium, .large] : [.large])
                    .presentationDragIndicator(.hidden)
            }
        }
        
        // Invisible toolbar item to handle the delay
        ToolbarItem(placement: .primaryAction) {
            Color.clear
                .frame(width: 0, height: 0)
                .task {
                    try? await Task.sleep(for: .seconds(0.2))
                    showToolbarItems = true
                }
        }
        
        ToolbarSpacer(.fixed)
        
        #if os(macOS)
        if showToolbarItems {
            ToolbarItemGroup(placement: .primaryAction) {
                ToolsToggleView(config: $chat.config)
            }
            
            ToolbarSpacer(.fixed)
            
            ToolbarItem(placement: .primaryAction) {
                Picker(selection: $chat.config.thinkingBudget) {
                    ForEach(ThinkingBudget.allCases, id: \.self) { budget in
                        Label(budget.displayName, systemImage: budget.systemImage)
                            .tag(budget)
                    }
                } label: {
                    Label("Thinking Budget", systemImage: "timer")
                }
                .labelsHidden()
                .pickerStyle(.segmented)
            }
            
            ToolbarSpacer(.fixed)
            
            ToolbarItem(placement: .primaryAction) {
                ModelMenuPicker(selectedModel: $chat.config.model)
            }
            
            
            if chat.status == .temporary {
                ToolbarSpacer(.fixed)
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        chat.status = .normal
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                    .popoverTip(TemporaryChatTip())
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Section {
                    Button("Edit Last Message") {
                        guard let lastUserMessage = chat.currentThread.last(where: { $0.role == .user }) else { return }
                        isFocused = .textEditor // this isnt doing anything (on macos at least)
                        chat.inputManager.setupEditing(message: lastUserMessage)
                    }
                    .keyboardShortcut("e")
                    .disabled(chat.status == .quick || chat.isReplying)
                    
                    Button("Regen Last Message") {
                        guard !chat.isReplying, let last = chat.currentThread.last else { return }
                        Task {
                            await chat.regenerate(message: last)
                        }
                    }
                    .keyboardShortcut("r")
                }
                
                Section {
                    Button("Reset Context") {
                        guard !chat.isReplying, let last = chat.currentThread.last else { return }
                        chat.resetContext(at: last)
                    }
                    .keyboardShortcut("k")
                    
                    Button("Delete Last Message", role: .destructive) {
                        chat.deleteLastMessage()
                        chat.errorMessage = nil
                    }
                    .keyboardShortcut(.delete)
                }
            }
        }
        #endif
    }
    
    private func toggleInspector() {
        showingInspector.toggle()
    }
}

#if os(macOS)
extension ToolbarItemPlacement {
    static let searchPanel = accessoryBar(id: "com.SilverMarcs.LynkChat.searchPanel")
}
#endif
