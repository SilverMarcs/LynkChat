//
//  ChatInputViewOld.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import TipKit

struct ChatInputViewOld: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat

    @State private var isExpanded = false
    @State private var showExpandButton = false
//    @State private var showPickers = false
//    @State private var showPQuickControls = false
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(spacing: 5) {
                if chat.inputManager.state == .editing {
                    cancelEditing
                }

                ChatInputMenu(chat: chat)
            }
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    #if os(macOS)
                    TipView(PlusButtonTip())
                        .frame(height: 30)
                        .padding(.bottom, 20)
                    #endif
                    
                    if !chat.inputManager.dataFiles.isEmpty {
                        DataFilesView(dataFiles: chat.inputManager.dataFiles, edge: .leading) { file in
                            withAnimation {
                                chat.inputManager.dataFiles.removeAll(where: { $0 == file })
                            }
                        }
                        .padding(2)
                        .padding(.bottom, -2)
                        
//                        Divider()
                    }
                    
                    InputEditor(chat: chat)
                        .frame(minHeight: 15)
                        .padding(.leading, 2)
                        .onChange(of: chat.inputManager.prompt) {
                            showExpandButton = chat.inputManager.prompt.contains("\n")
                        }
                }
                .padding(4)
                
                VStack {
                    if showExpandButton || isExpanded || !chat.inputManager.dataFiles.isEmpty {
                        expandInput
                            .padding(3)
                        
                        Spacer()
                    }
                    
                    ActionButton(isStop: chat.isReplying) {
                        chat.isReplying ? chat.stopStreaming() : sendInput()
                    }
                    .if(showExpandButton) {
                        $0.padding(2)
                    }
                }
            }
            .padding(2)
            .roundedRectangleOverlay(radius: 15)
        }
        .modifier(CommonInputStyling())
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
    
    var cancelEditing: some View {
        Button {
            withAnimation {
                chat.inputManager.reset()
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                #if os(macOS)
                .font(.system(size: 25, weight: .semibold))
                #else
                .font(.system(size: 31, weight: .semibold))
                #endif
                .foregroundStyle(.red)
        }
        .transition(.symbolEffect(.appear))
        .buttonStyle(.plain)
        .keyboardShortcut(.cancelAction)
    }
    
//    private var quickControls: some View {
//        Button(action: { showPickers.toggle() }) {
//            Image(systemName: "gearshape")
//                .font(.system(size: 14, weight: .semibold))
//                .padding(5)
//                .background(
//                    RoundedRectangle(cornerRadius: 13, style: .continuous)
//                        .fill(.quaternary)
//                )
//        }
//        .buttonStyle(.plain)
//        .opacity(0.7)
//        .popover(isPresented: $showPickers) {
//            InputModelPickers(chat: chat)
//        }
//    }
    
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
}
