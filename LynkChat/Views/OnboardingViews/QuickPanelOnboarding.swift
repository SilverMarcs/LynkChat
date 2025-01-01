//
//  QuickPanelOnboarding.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

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
                        Text("⌥ + Space")
                            .monospaced()
                    } label: {
                        Text("Global shortcut")
                    }
                    
                    ModelPicker(selectedModel: $modelConfig.quickModel)
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
