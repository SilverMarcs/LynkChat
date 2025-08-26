//
//  ModelOnboarding.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI
import SwiftData

struct ModelOnboarding: View {
    @State var chatConfig: ChatConfigDefaults = .init()
    
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
                }
            },
            footerText: "Configure other models in Settings."
        )
    }
}

#Preview {
    ModelOnboarding()
        .frame(width: 500, height: 500)
}
