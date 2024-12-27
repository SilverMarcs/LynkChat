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
        VStack(alignment: .leading, spacing: 8) {
            if !chat.inputManager.dataFiles.isEmpty {
                DataFilesView(dataFiles: chat.inputManager.dataFiles, adaptiveGrid: true) { file in
                    withAnimation {
                        chat.inputManager.dataFiles.removeAll(where: { $0 == file })
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
                
                Divider()
                    .padding(.vertical, -1)
            }
            
            TipView(PlusButtonTip())
                .frame(height: 30)
            
            InputEditor(chat: chat)
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .onChange(of: chat.inputManager.prompt) {
                    showExpandButton = chat.inputManager.prompt.contains("\n")
                }
                .overlay(alignment: .topTrailing) {
                    if showExpandButton {
                        expandInput
                    }
                }
            
            HStack {
                ChatInputMenu(chat: chat)
                
                configInfo
                
                Spacer()
                
                if chat.inputManager.state == .editing {
                    cancelEditing
                } else {
                    Button {
//                        chat.startDictation()
                    } label: {
                        Image(systemName: "mic")
                    }
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
                }
                
                ActionButton(isStop: chat.isReplying) {
                    chat.isReplying ? chat.stopStreaming() : sendInput()
                }
            }
        }
        .padding(4)
        .roundedRectangleOverlay(radius: 14, style: .circular)
        .modifier(CommonInputStyling())
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
            Text("Cancel Editing")
                .padding(4)
                .font(.system(size: 12))
                .padding(.horizontal, 2)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(.red.quinary)
                )
                .foregroundStyle(.red)
                .opacity(0.8)
        }
        .transition(.symbolEffect(.appear))
        .buttonStyle(.plain)
        .keyboardShortcut(.cancelAction)
    }

    private var configInfo: some View {
        HStack(spacing: 4) {
//            CustomToolsView(tools: $chat.config.tools, isGoogle: chat.config.provider.type == .google)
//                .toggleStyle(.button)
//                .labelStyle(.iconOnly)
//                .buttonStyle(.borderless)
//                .padding(.trailing, 5)
            
            Picker("Model", selection: $chat.config.model) {
                ForEach(LynkModel.allCases) { model in
                    Text(model.name)
                        .tag(model)
                }
            }
            .buttonStyle(.borderless)
            .labelsHidden()
            .opacity(0.65)
        }
    }
    
    private func sendInput() {
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
