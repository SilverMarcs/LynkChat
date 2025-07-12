//
//  InputEditor.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/12/2024.
//

import SwiftUI

struct InputEditor: View {
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat
    @FocusState var isFocused: FocusedField?
    
    var body: some View {
        // TODO: split into diff view pehraps inloen with multine singlelineviews
        TextField("Send a prompt", text: $chat.inputManager.prompt, axis: .vertical)
            .padding(.leading, 6)
            .focused($isFocused, equals: .textEditor)
            .lineLimit(10, reservesSpace: false)
            .onSubmit {
                if config.enterToSend {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    Task { @MainActor in
                        await chat.sendInput()
                    }
                } else {
                    chat.inputManager.prompt += "\n"
                }
            }
    }
}
