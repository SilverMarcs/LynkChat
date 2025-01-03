//
//  APIKeyOnboarding.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI
import SwiftData

struct APIKeyOnboarding: View {
    @ObservedObject var modelConfig: ModelConfig = .shared
    @ObservedObject var config: AppConfig = .shared
    
    var body: some View {
        GenericOnboardingView(
            icon: modelConfig.defaultModel.imageName,
            useSFSymbol: false,
            iconColor: Color(hex: modelConfig.defaultModel.color),
            title: "Chat with various LLMs",
            content: {
                Form {
                    Section {
                        ModelPicker(selectedModel: $modelConfig.defaultModel)
                    }
                    #if os(iOS)
                    .listRowBackground(Color(.secondarySystemBackground))
                    #endif
                    
                    Section {
                        Toggle("Enter to send messages", isOn: $config.enterToSend)
                    }
                    #if os(iOS)
                    .listRowBackground(Color(.secondarySystemBackground))
                    #endif
                }
            },
            footerText: "Configure other models in Settings."
        )
    }
}

#Preview {
    APIKeyOnboarding()
        .frame(width: 500, height: 500)
}
