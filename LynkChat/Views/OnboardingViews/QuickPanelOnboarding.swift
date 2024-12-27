//
//  QuickPanelOnboarding.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

#if os(macOS)
import SwiftUI

struct QuickPanelOnboarding: View {
    @ObservedObject var modelConfig: ModelConfig = .shared
    
    var body: some View {
        GenericOnboardingView(
            icon: "bolt.fill",
            iconColor: .yellow,
            title: "Spotlight-like Floating Panel",
            content: {
                Form {
                    LabeledContent {
//                        KeyboardShortcuts.Recorder(for: .togglePanel)
                        Text("⌥ + Space")
                    } label: {
                        Text("Global shortcut")

                    }
                    
//                    ModelPicker(model: $provider.liteModel, models: provider.models, label: "Quick Panel Model")
                    
                    Picker("Model", selection: $modelConfig.quickModel) {
                        ForEach(ChatModel.allCases) { model in
                            Text(model.rawValue)
                                .tag(model)
                        }
                    }
                }
            },
            footerText: "Access from anywhere in the OS"
        )
    }
}


 #Preview {
     QuickPanelOnboarding()
         .frame(width: 500, height: 500)
 }
#endif
