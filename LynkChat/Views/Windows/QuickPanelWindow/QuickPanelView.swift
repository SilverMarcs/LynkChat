//
//  QuickPanelView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 12/07/2024.
//

import SwiftUI
import SwiftData

struct QuickPanelView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ChatVM.self) private var chatVM

    @Bindable var chat: Chat
    var updateHeight: (CGFloat) -> Void
    var toggleVisibility: () -> Void

    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            textfieldView
                .padding(15)
                .padding(.trailing, -2)
                .frame(height: 57)
            
            if !chat.inputManager.dataFiles.isEmpty {
                DataFilesView(dataFiles: chat.inputManager.dataFiles) { file in
                    chat.inputManager.dataFiles.removeAll { $0 == file }
                }
                .safeAreaPadding(.horizontal)
                .safeAreaPadding(.vertical, 10)
            }
            
            if chat.currentThread.isEmpty {
                Spacer()
            } else {
                Divider()
                
                ChatDetail(chat: chat)
                    .scrollContentBackground(.hidden)
                
                bottomView
            }
        }
        .frame(width: 650)
        .onChange(of: chatVM.isQuickPanelPresented) {
            if chatVM.isQuickPanelPresented {
                isFocused = true
                if !chat.currentThread.isEmpty {
                    updateHeight(500)
                }
            } else {
                DispatchQueue.main.async {
                    updateHeight(57)
                }
            }
        }
        // MUST NOT DO THIS> IT PREVENTS TEXT SELECTION
//        .onChange(of: isFocused) {
//            isFocused = true
//        }
        .onChange(of: chat.inputManager.dataFiles.isEmpty) {
            if chat.inputManager.dataFiles.isEmpty && chat.currentThread.isEmpty {
                updateHeight(57)
            } else {
                updateHeight(500)
            }
        }
    }
    
    @ViewBuilder
    var textfieldView: some View {
        HStack(spacing: 12) {
            Menu {
                ModelPicker(selectedModel: $chat.config.model)
                
                Menu {
                    QPToolsConfigView(config: $chat.config)
                } label: {
                    Label("Tools", systemImage: "gear")
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            
            TextField("Ask Anything...", text: $chat.inputManager.prompt, axis: .vertical)
                .allowsTightening(true)
                .focused($isFocused)
                .font(.system(size: 25))
                .textFieldStyle(.plain)
                .onSubmit {
                    send()
                }
            
            Button(action: chat.isReplying ? chat.stopStreaming : send) {
                Image(systemName: chat.isReplying ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.largeTitle).fontWeight(.semibold)
            }
            .foregroundStyle((chat.isReplying ? AnyShapeStyle(.background) : AnyShapeStyle(.white)), (chat.isReplying ? .red : .accent))
            .buttonStyle(.plain)
            .contentTransition(.symbolEffect(.replace, options: .speed(2)))
        }
    }
    
    private var bottomView: some View {
        HStack {
            Group {
                Button {
                    resetChat()
                } label: {
                    Image(systemName: "delete.left")
                        .imageScale(.medium)
                }
                .keyboardShortcut(.delete, modifiers: [.command, .shift])
                
                Group {
                    Text(chat.config.model.name)
                    
//                    ForEach(chat.config.tools.enabledTools) { tool in
//                        Image(systemName: tool.icon)
//                    }
                }
                .font(.caption)
                
                Spacer()
                
                Button {
                    addToDB()
                } label: {
                    Image(systemName: "plus.square.on.square")
                        .imageScale(.medium)
                }
                .disabled(chat.currentThread.isEmpty)
                .keyboardShortcut("N", modifiers: [.command])
                
            }
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
            .padding(7)
        }
        .background(.regularMaterial)
    }
    
    private func resetChat() {
        updateHeight(57)
        
        chat.deleteAllMessages()
//        chat.inputManager.dataFiles.removeAll()
        chat.config.model = ModelConfig.shared.quickModel
    }
    
    private func addToDB() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.keyWindow?.makeKeyAndOrderFront(nil)
        
        Task {
            let newChat = await chat.copy()
            newChat.title = "(↯) " + newChat.title
            chatVM.fork(newChat: newChat)
            resetChat()
            
            if let mainWindow = NSApp.windows.first(where: { $0.identifier?.rawValue == "chats" }) {
                mainWindow.makeKeyAndOrderFront(nil)
            }
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    private func send() {
        if chat.inputManager.prompt.isEmpty {
            return
        }
        
        Task {
            await chat.sendInput()
        }
        
        updateHeight(500)
    }
}

#Preview {
    QuickPanelView(chat: .mockChat, updateHeight: { _ in }, toggleVisibility: {})
}
