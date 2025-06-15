//
//  InputArea.swift
//  LynkChat
//
//  Created by Zabir Raihan on 19/12/2024.
//

import SwiftUI
import SwiftData
import TipKit

struct InputArea: View {
    @Environment(ChatVM.self) private var chatVM
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat

    @State private var isExpanded = false
    @State private var showExpandButton = false
    
    @FocusState var isFocused: FocusedField?
    
    var body: some View {
        HStack(alignment: .bottom) {
            ChatInputMenu(chat: chat)
            
            if chat.inputManager.state == .editing {
                cancelEditing
            }
                
            VStack(alignment: .leading) {
                if !chat.inputManager.dataFiles.isEmpty {
                    DataFilesView(dataFiles: chat.inputManager.dataFiles) { file in
                        if chat.inputManager.dataFiles.count == 1 {
                            chat.inputManager.dataFiles.removeAll(where: { $0 == file })
                        } else {
                            withAnimation {
                                chat.inputManager.dataFiles.removeAll(where: { $0 == file })
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                }
                
                InputEditor(chat: chat)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .onChange(of: chat.inputManager.prompt) {
                        showExpandButton = chat.inputManager.prompt.contains("\n")
                    }
                    .overlay(alignment: .topTrailing) {
                        if showExpandButton {
                            expandInput
                        }
                    }
                    .padding(5.5)
                    .glassEffect(in: .rect(cornerRadius: 16))
            }
            
            ActionButton(isStop: chat.isReplying) {
                chat.isReplying ? chat.stopStreaming() : sendInput()
            }
        }
        .padding(12)
        .pasteHandler(chat: chat)
//        .modifier(CommonInputStyling())
    }
        
    var expandInput: some View {
        Button {
            isExpanded.toggle()
        } label: {
            Image(systemName: isExpanded ? "arrow.up.right.and.arrow.down.left" : "arrow.down.left.and.arrow.up.right")
                .padding(3)
        }
        .transition(.symbolEffect(.appear))
        .buttonStyle(.plain)
        .sheet(isPresented: $isExpanded) {
            ExpandedInputEditor(prompt: $chat.inputManager.prompt)
        }
    }
    
    @ViewBuilder
    var cancelEditing: some View {
        Button {
            withAnimation {
                chat.inputManager.reset()
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.largeTitle).fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.7), .clear)
                .glassEffect(.regular.tint(.red.opacity(0.6)))
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.cancelAction)
    }

    private var configInfo: some View {
        HStack(spacing: 4) {
            if chat.config.model.supportsTool {
                Divider()
                    .frame(height: 15)
                
                ToolsBarView(config: $chat.config)
            }
            
            Divider()
                .frame(height: 15)
            
            ModelPicker(selectedModel: $chat.config.model)
                .buttonStyle(.borderless)
                .labelsHidden()
                .opacity(0.65)
        }
    }
    
    private func sendInput() {
        chatVM.searchText = ""
        Task { @MainActor in
            await chat.sendInput()
        }
    }
}

import SwiftData
#Preview {
    ChatDetail(chat: .mockChat)
        .environment(ChatVM())
        .frame(width: 450)
}
