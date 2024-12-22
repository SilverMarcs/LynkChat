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
        Group {
            ProviderPicker(provider: $chat.config.provider, providers: providers) { provider in
                chat.config.model = provider.chatModel
            }
//            .frame(width: 80)
            
            ModelPicker(model: $chat.config.model, models: chat.config.provider.chatModels)
        }
        .buttonStyle(.borderless)
    }
}

#Preview {
    InputModelPickers(chat: .mockChat)
        .frame(width: 250)
}
