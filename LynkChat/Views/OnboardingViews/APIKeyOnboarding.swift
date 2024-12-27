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
            title: "Enter your API Key",
            content: {
                Form {
                    Section {
                        Picker("Model", selection: $modelConfig.defaultModel) {
                            ForEach(LynkModel.allCases) { model in
                                Text(model.rawValue)
                                    .tag(model)
                            }
                        }
                    }
                    #if os(iOS)
                    .listRowBackground(Color(.secondarySystemBackground))
                    #endif
                }
            },
            footerText: "Configure other providers in Settings."
        )
    }
}

#Preview {
    APIKeyOnboarding()
        .frame(width: 500, height: 500)
}
