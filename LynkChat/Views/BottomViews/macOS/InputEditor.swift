//
//  InputEditor.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/12/2024.
//

import SwiftUI

struct InputEditor: View {
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat
    @FocusState var isFocused: FocusedField?
    
    var body: some View {
        // TODO: split into diff view pehraps inloen with multine singlelineviews
        Group {
            if config.enterToSend {
                TextField(placeHolder, text: $chat.inputManager.prompt, axis: .vertical)
                    .lineLimit(25, reservesSpace: false)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        if NSApp.currentEvent?.modifierFlags.contains(.shift) == true {
                            chat.inputManager.prompt += "\n"
                        } else {
                            Task { @MainActor in
                                await chat.sendInput()
                            }
                        }
                    }
            } else {
                ZStack(alignment: .leading) {
                    if chat.inputManager.prompt.isEmpty {
                        Text(placeHolder)
                            .padding(.leading, 1)
                            .foregroundStyle(.placeholder)
                    }
                    
                    TextEditor(text: $chat.inputManager.prompt)
                        .padding(.leading, -4)
                        .frame(maxHeight: 370)
                        .fixedSize(horizontal: false, vertical: true)
                        .scrollContentBackground(.hidden)
                }
                .font(.body)
            }
        }
        .focused($isFocused, equals: .textEditor)
        .task {
            guard chatVM.selections.count == 1 else { return }
            isFocused = .textEditor
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
                    isFocused = .textEditor
                } label: {
                    Image(systemName: "pencil")
                }
                .keyboardShortcut("l")
            }
        }
        
        var placeHolder: String {
            "Send a prompt"
        }
    }
}
