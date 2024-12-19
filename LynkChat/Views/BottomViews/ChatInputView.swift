//
//  ChatInputView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 19/12/2024.
//

import SwiftUI
import SwiftData
import TipKit

struct ChatInputView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat

    @State private var isExpanded = false
    @State private var showExpandButton = false
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]
    
    var body: some View {
        VStack(spacing: 10) {
            if !chat.inputManager.dataFiles.isEmpty {
                DataFilesView(dataFiles: chat.inputManager.dataFiles, edge: .leading) { file in
                    withAnimation {
                        chat.inputManager.dataFiles.removeAll(where: { $0 == file })
                    }
                }
                .padding(.bottom, 5)
            }
            
            InputEditor(chat: chat)
                .padding(3)
//                .onChange(of: chat.inputManager.prompt) {
//                    showExpandButton = chat.inputManager.prompt.contains("\n")
//                }
            
//            Divider()
            
            HStack {
                ChatInputMenu(chat: chat)
                
                #if os(macOS)
                HStack {
                    ToolsController(tools: $chat.config.tools, isGoogle: chat.config.provider.type == .google)
                        .toggleStyle(.button)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .font(.title3)
                }
                .padding(3)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.background.secondary)
                )
                .roundedRectangleOverlay(radius: 8)
                #else
                Menu {
                    ToolsController(tools: $chat.config.tools, isGoogle: chat.config.provider.type == .google)
                } label: {
                    Image(systemName: "hammer.fill")
                        .opacity(0.9)
                }
                .controlSize(.small)
                .foregroundStyle(.teal)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.background.secondary)
                )
                .fixedSize()
                #endif

                
                if horizontalSizeClass != .compact {
                    ProviderPicker(provider: $chat.config.provider, providers: providers) { provider in
                        chat.config.model = provider.chatModel
                    }
                        .labelsHidden()
                        .buttonStyle(.borderless)
                        .fixedSize()
                        .opacity(0.7)
                        .padding(.trailing, -5)
                    
                    ModelPicker(model: $chat.config.model, models: chat.config.provider.chatModels)
                        .labelsHidden()
                        .buttonStyle(.borderless)
                        .fixedSize()
                        .opacity(0.7)
                        .textCase(.uppercase)
                }
                
                Spacer()
                
                if chat.inputManager.state == .editing {
                    cancelEditing
                }
                
                ActionButton(isStop: chat.isReplying) {
                    chat.isReplying ? chat.stopStreaming() : sendInput()
                }
            }
        }
        .padding(5)
        .roundedRectangleOverlay(radius: radius)
        .modifier(CommonInputStyling())
    }
    
    var radius: CGFloat {
        #if os(macOS)
        16
        #else
        24
        #endif
    }
    
    var truncateLimit: Int {
        #if os(macOS)
        130
        #else
        35
        #endif
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
        Text("Editing")
            .foregroundStyle(.secondary)
        
        Button {
            withAnimation {
                chat.inputManager.reset()
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title).fontWeight(.semibold)
                .foregroundStyle(.red)
        }
        .transition(.symbolEffect(.appear))
        .buttonStyle(.plain)
        .keyboardShortcut(.cancelAction)
    }
    
    private func sendInput() {
        #if os(iOS)
//        isFocused = nil // doesn't work
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
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
