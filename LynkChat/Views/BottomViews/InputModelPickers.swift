//
//  InputModelPickers.swift
//  LynkChat
//
//  Created by Zabir Raihan on 20/12/2024.
//

import SwiftUI
import SwiftData

struct InputModelPickers: View {
    @Bindable var chat: Chat
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]
    
    var body: some View {
        Form {
            ProviderPicker(provider: $chat.config.provider, providers: providers) { provider in
                chat.config.model = provider.chatModel
            }
            
            ModelPicker(model: $chat.config.model, models: chat.config.provider.chatModels)
            
            LabeledContent {
//                ControlGroup {}
                ToolsController(tools: $chat.config.tools, isGoogle: chat.config.provider.type == .google)
                    .toggleStyle(.button)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)

            } label: {
                Text("Plugins")
            }
        }
        .padding(-5)
        .frame(width: 250)
        .formStyle(.grouped)
    }
}

#Preview {
    InputModelPickers(chat: .mockChat)
        .frame(width: 250)
}
