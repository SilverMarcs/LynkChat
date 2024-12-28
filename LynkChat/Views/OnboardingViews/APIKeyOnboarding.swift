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
    
    var body: some View {
        GenericOnboardingView(
            icon: "cpu.fill",
            iconColor: Color(hex: modelConfig.defaultModel.color),
            title: "Select default model",
            content: {
                Form {
                    Section {
                        Picker("Model", selection: $modelConfig.defaultModel) {
                            ForEach(ChatModel.allCases) { model in
                                Text(model.name)
                                    .tag(model)
                            }
                        }
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
