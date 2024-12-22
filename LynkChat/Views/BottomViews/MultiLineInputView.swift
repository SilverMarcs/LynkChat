//
//  MultiLineInputView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 19/12/2024.
//

import SwiftUI
import SwiftData

struct MultiLineInputView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat

    @State private var isExpanded = false
    @State private var showExpandButton = false
    @State private var showPickers = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !chat.inputManager.dataFiles.isEmpty {
                DataFilesView(dataFiles: chat.inputManager.dataFiles, edge: .leading) { file in
                    withAnimation {
                        chat.inputManager.dataFiles.removeAll(where: { $0 == file })
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
                
                Divider()
            }
            
            HStack(alignment: .top) {
                InputEditor(chat: chat)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3)
                    .onChange(of: chat.inputManager.prompt) {
                        showExpandButton = chat.inputManager.prompt.contains("\n")
                    }
                
                if showExpandButton {
                    expandInput
                }
            }
            
            HStack {
                ChatInputMenu(chat: chat)
                
                if horizontalSizeClass != .compact {
                    quickControls
                }
                
                Spacer()
                
                if chat.inputManager.state == .editing {
                    cancelEditing
                } else {
//                    resetContext
                    // TODO: Dictation here
                }
                
                ActionButton(isStop: chat.isReplying) {
                    chat.isReplying ? chat.stopStreaming() : sendInput()
                }
            }
        }
        .padding(4)
        .roundedRectangleOverlay(radius: radius)
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

    private var quickControls: some View {
        Button(action: { showPickers.toggle() }) {
            Text("Config")
                .padding(4)
                .padding(.horizontal, 2)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .circular)
                        .fill(.accent.quinary)
                )
        }
        #if os(macOS)
        .buttonStyle(.link)
        #endif
        .opacity(0.7)
        .popover(isPresented: $showPickers) {
            InputModelPickers(chat: chat)
        }
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
    
    var radius: CGFloat {
        #if os(macOS)
        16
        #else
        24
        #endif
    }
}

import SwiftData
#Preview {
    ChatDetail(chat: .mockChat)
        .environment(ChatVM())
        .frame(width: 450)
}
