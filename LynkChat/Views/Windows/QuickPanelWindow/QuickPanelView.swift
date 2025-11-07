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

    @Bindable var chat: Chat
    var updateHeightState: (QuickPanelHeight) -> Void
    @Environment(ChatVM.self) var chatVM
    @Environment(\.openWindow) private var openWindow

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
                    updateHeightBasedOnContent()
                }
                .safeAreaPadding(.horizontal)
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
        .transaction { $0.animation = nil }
        .frame(width: 650)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
        }
        .onChange(of: [chat.inputManager.dataFiles.count, chat.currentThread.count] ) {
            updateHeightBasedOnContent()
        }
    }
    
    private func updateHeightBasedOnContent() {
        let newState: QuickPanelHeight
        
        if !chat.currentThread.isEmpty {
            newState = .expanded()
        } else if !chat.inputManager.dataFiles.isEmpty {
            newState = .files()
        } else {
            newState = .collapsed()
        }
        
        updateHeightState(newState)
    }
    
    var textfieldView: some View {
        HStack(spacing: 12) {
            Menu {
                ForEach(ChatModel.allCases, id: \.self) { model in
                    Button {
                        chat.config.model = model
                    } label: {
                        HStack {
                            Label(model.name, image: model.imageName)
                                .labelStyle(.titleAndIcon)
                            
                            if model == chat.config.model {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(chat.config.model.imageName)
                    .resizable()
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .overlay(
                Button {
                    resetChat()
                } label: {
                    Color.clear
                }
                .keyboardShortcut(.delete, modifiers: [.command, .shift])
                .opacity(0)
            )
        
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
                    .scaleEffect(1.1)
            }
            .foregroundStyle((chat.isReplying ? AnyShapeStyle(.background) : AnyShapeStyle(.white)), (chat.isReplying ? .red : .accentColor))
            .buttonStyle(.plain)
//            .contentTransition(.symbolEffect(.replace, options: .speed(2)))
        }
        .pasteHandler(chat: chat, isQuickPanel: true)
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

                Spacer()
                
                Button {
                    addToDB()
                } label: {
                    Image(systemName: "plus.square.on.square")
                        .imageScale(.medium)
                }
                .disabled(chat.currentThread.isEmpty)
                .keyboardShortcut("N", modifiers: [.command, .shift])
                
            }
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
            .padding(7)
        }
    }
    
    private func resetChat() {
        chat.deleteAllMessages()
        chat.inputManager.dataFiles.removeAll()
        // Reset to default Quick Panel model
        let defaults = ChatConfigDefaults()
        chat.config.models = [defaults.quickDefaultModel]
        chat.config.systemPrompt = defaults.quickSystemPrompt
        chat.config.temperature = .precise
        
        updateHeightState(.collapsed())
    }
    
    private func addToDB() {
        openWindow(id: WindowID.chats)
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
    }
}

#Preview {
    QuickPanelView(chat: .mockChat, updateHeightState: { _ in })
}
