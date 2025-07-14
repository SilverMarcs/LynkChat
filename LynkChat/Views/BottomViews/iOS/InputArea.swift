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
