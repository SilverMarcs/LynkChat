//
//  ImageInputView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct ImageInputView: View {
    @Bindable var session: ImageSession
    @FocusState var isFocused: FocusedField?
    
    var body: some View {
        HStack {
            ImageSessionInputMenu(session: session)
                
            TextField("Prompt", text: $session.prompt, axis: .vertical)
                .onSubmit( { sendInput() } )
                .textFieldStyle(.plain)
                .focused($isFocused, equals: .imageInput)
                .onKeyPress(.upArrow) {
                    if session.prompt.isEmpty {
                        if let lastPrompt = session.imageGenerations.last?.config.prompt {
                            session.prompt = lastPrompt
                            return .handled
                        }
                    }
                    return .ignored
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .glassEffect(in: .rect(cornerRadius: 24))
                
            Button {
                sendInput()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 15)).fontWeight(.bold)
            }
            .opacity(0.85)
            .controlSize(.large)
            .tint(.accent)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
//                .keyboardShortcut(chat.isReplying ? "d" : .return)
        }
        .ignoresSafeArea()
        .padding(11)
        #if os(macOS)
        .task {
            isFocused = .imageInput
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Focus") {
                    isFocused = .imageInput
                }
                .keyboardShortcut("l")
            }
        }
        #endif
    }
    
    private func sendInput() {
        guard !session.prompt.isEmpty else { return }
        
        #if !os(macOS)
        isFocused = nil
        #endif
        Task {
            await session.send()
        }
    }
    
    var imageSize: CGFloat {
        #if os(macOS)
        21
        #else
        31
        #endif
    }
}

#Preview {
    ImageInputView(session: .mockImageSession)
}
