//
//  InputArea.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import TipKit

struct InputArea: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var config = AppConfig.shared
    
    var chat: Chat
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if chat.inputManager.state == .editing {
                    cancelEditing
                }
                
                if !chat.inputManager.dataFiles.isEmpty {
                    HStack {
                        DataFilesView(dataFiles: chat.inputManager.dataFiles) { file in
                            withAnimation {
                                chat.inputManager.dataFiles.removeAll(where: { $0 == file })
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    var bodyOld: some View {
        HStack(alignment: .bottom) {
            VStack(spacing: 5) {
                if chat.inputManager.state == .editing {
                    cancelEditing
                }

                ChatInputMenu(chat: chat)
            }
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Spacer(minLength: 0)
                        
                        if !chat.inputManager.dataFiles.isEmpty {
                            DataFilesView(dataFiles: chat.inputManager.dataFiles) { file in
                                withAnimation {
                                    chat.inputManager.dataFiles.removeAll(where: { $0 == file })
                                }
                            }
                            .padding(2)
                            .padding(.bottom, -2)
                        }

                        InputEditor(chat: chat)
                            .frame(minHeight: 16)
                            .padding(.leading, 3)
                        
                        Spacer(minLength: 0)
                    }
                }
                .padding(4)
                
                ActionButton(isStop: chat.isReplying) {
                    chat.isReplying ? chat.stopStreaming() : sendInput()
                }
            }
            .padding(2)
            .roundedRectangleOverlay()
        }
        .modifier(CommonInputStyling())
    }

    var cancelEditing: some View {
        Button {
            withAnimation {
                chat.inputManager.reset()
            }
        } label: {
            Label("Cancel Editing", systemImage: "xmark")
        }
        .buttonStyle(.glass)
        .keyboardShortcut(.cancelAction)
    }
    
    
    private func sendInput() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        Task {
            await chat.sendInput()
        }
    }
}

import SwiftData
#Preview {
    ChatDetail(chat: .mockChat)
}
