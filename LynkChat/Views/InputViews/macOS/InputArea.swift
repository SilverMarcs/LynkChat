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
    @Bindable var chat: Chat

    @FocusState var isFocused: FocusedField?
    
    var body: some View {
        HStack(alignment: .bottom) {
            ChatInputMenu(chat: chat)
                .offset(y: -1)
            
            if chat.inputManager.state == .editing {
                Button {
                    withAnimation {
                        chat.inputManager.reset()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title).fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.7), .clear)
                        .glassEffect(.regular.tint(.red.opacity(0.6)))
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
                .offset(y: -3)
                .scaleEffect(1.1)
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
//                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                }
                
                InputEditor(chat: chat)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .padding(6)
                    .glassEffect(in: .rect(cornerRadius: 16))
            }
            
            Button(action: {
                chat.isReplying ? chat.stopStreaming() : sendInput()
            }) {
                Image(systemName: chat.isReplying ? "stop.fill" : "arrow.up")
                    .font(.system(size: 15)).fontWeight(.bold)
            }
            .opacity(0.85)
            .controlSize(.large)
            .tint(chat.isReplying ? .red : .accent)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .keyboardShortcut(chat.isReplying ? "d" : .return)
            .offset(y: -2)
        }
        .padding(12)
        .pasteHandler(chat: chat)
    }
    
    private func sendInput() {
        Task {
            await chat.sendInput()
        }
    }
}

import SwiftData
#Preview {
    ChatDetail(chat: .mockChat)
        .frame(width: 450)
}
