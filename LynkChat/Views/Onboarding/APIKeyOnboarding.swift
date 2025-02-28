//
//  APIKeyOnboarding.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI
import SwiftData

struct APIKeyOnboarding: View {
    @ObservedObject var chatConfig: ChatConfigDefaults = .shared
    @ObservedObject var config: AppConfig = .shared
    
    var body: some View {
        GenericOnboardingView(
            icon: chatConfig.defaultModel.imageName,
            useSFSymbol: false,
            iconColor: Color(hex: chatConfig.defaultModel.color),
            title: "Chat with various LLMs",
            content: {
                Form {
                    Section {
                        ModelPicker(selectedModel: $chatConfig.defaultModel)
                    }
                    #if os(iOS)
                    .listRowBackground(Color(.secondarySystemBackground))
                    #endif
                    
                    Section {
                        Toggle("Enter to send messages", isOn: $config.enterToSend)
                    } footer: {
                        #if os(macOS)
                        Text("Keep disabled for better performance.")
                        #endif
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
