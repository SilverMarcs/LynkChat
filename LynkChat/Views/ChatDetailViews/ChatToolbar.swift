//
//  ChatToolbar.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ChatToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Bindable var chat: Chat
    
    @State private var showToolbarItems: Bool = false
    @State private var showingInspector: Bool = false
    @State private var showingSecondaryModels = false
    
    @FocusState private var isFocused: FocusedField?
    
    private let chatVM = ChatVM.shared
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Color.clear
                .frame(width: 0, height: 0)
                .task {
                    try? await Task.sleep(for: .seconds(0.2))
                    showToolbarItems = true
                }
        }
        
        ToolbarSpacer(.fixed)
            ToolbarItem(placement: .navigation) {
                Button {
                    showingInspector.toggle()
                } label: {
                    Label("Inspector", systemImage: "slider.vertical.3")
                }
                .keyboardShortcut(".")
                .sheet(isPresented: $showingInspector) {
                    ChatInspector(chat: chat)
                }
            }
        
        if showToolbarItems {
//            ToolbarItemGroup(placement: .primaryAction) {
//                ToolsToggleView(config: $chat.config)
//            }
            
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
            
            ToolbarItemGroup(placement: .primaryAction) {
//                ModelMenuPicker(selectedModels: $chat.config.models)
                ModelPicker(selectedModel: $chat.config.model)
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
        }
            
        ToolbarItemGroup(placement: .keyboard) {
            Section {
                Button("Send/Stop Message") {
                    chat.isReplying ? chat.stopStreaming() : sendInput()
                }
                .keyboardShortcut(chat.isReplying ? "d" : .return)
                
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
    
    private func sendInput() {
        Task {
            await chat.sendInput()
        }
    }
}

extension ToolbarItemPlacement {
    static let searchPanel = accessoryBar(id: "com.SilverMarcs.LynkChat.searchPanel")
}
    
