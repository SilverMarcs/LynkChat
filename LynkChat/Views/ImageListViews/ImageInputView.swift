//
//  ImageInputView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageInputView: View {
    @Bindable var session: ImageSession
    @FocusState var isFocused: FocusedField?
    
    var body: some View {
        HStack {
            ImageSessionInputMenu(session: session)
            
            TextField("Prompt", text: $session.config.prompt, axis: .vertical)
                .onSubmit( { sendInput() } )
                .textFieldStyle(.plain)
                .focused($isFocused, equals: .imageInput)
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
        }
        .ignoresSafeArea()
        .padding(11)
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
        #if os(macOS)
        .imagePasteHandler(session: session)
        #endif
    }
    
    private func sendInput() {
        Task {
            await session.send()
        }
    }
}

#Preview {
    ImageInputView(session: .mockImageSession)
}
