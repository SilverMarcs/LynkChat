//
//  InputEditor.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/12/2024.
//

import SwiftUI

struct InputEditor: View {
//    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat
    @FocusState var isFocused: FocusedField?
    
    var body: some View {
        ZStack(alignment: .leading) {
            if chat.inputManager.prompt.isEmpty {
                Text(placeHolder)
                    .padding(.leading, 1)
                    .foregroundStyle(.placeholder)
            }
            
            TextEditor(text: $chat.inputManager.prompt)
                .padding(.leading, -4)
                .frame(maxHeight: 350)
                .fixedSize(horizontal: false, vertical: true)
                .scrollContentBackground(.hidden)
//                .apply {
//                    if config.enterToSend {
//                        $0.onChange(of: chat.inputManager.prompt) { oldValue, newValue in
//                            let modifiers = NSApp.currentEvent?.modifierFlags
//                            if modifiers?.contains(.shift) != true && modifiers?.contains(.option) != true {
//                                let hasNewlineAtEnd = chat.inputManager.prompt.last?.isNewline == .some(true)
//                                let isDeleting = oldValue.count > chat.inputManager.prompt.count
//                                
//                                if hasNewlineAtEnd && !isDeleting {
//                                    chat.inputManager.prompt.removeLast()
//                                    isFocused = nil
//                                    Task {
//                                        await chat.sendInput()
//                                    }
//                                }
//                            }
//                        }
//                    } else {
//                        $0
//                    }
//                }
        }
        .font(.body)
        .focused($isFocused, equals: .textEditor)
        .task {
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
            "Ask Anything..."
        }
    }
}
