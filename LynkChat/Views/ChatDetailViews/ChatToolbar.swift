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
        
        #if os(macOS)
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
//            ModelPopoverPicker(selectedModel: $chat.config.model)
                ModelMenuPicker(selectedModel: $chat.config.model)
//                ModelPicker(selectedModel: $chat.config.model)
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
        #endif
    }
    
    private func toggleInspector() {
//        #if !os(macOS)
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//        #endif
        showingInspector.toggle()
    }
}

#Preview {
    VStack {
        Text("Hello, World!")
    }
    .frame(width: 700, height: 300)
    .toolbar {
        ChatToolbar(chat: .mockChat)
    }
}

#if os(macOS)
extension ToolbarItemPlacement {
    static let searchPanel = accessoryBar(id: "com.SilverMarcs.LynkChat.searchPanel")
}
#endif
