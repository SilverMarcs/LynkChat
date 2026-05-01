//
//  QuickPanelOnboarding.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct QuickPanelOnboarding: View {
    var body: some View {
        GenericOnboardingView(
            icon: "bolt.fill",
            iconColor: .yellow,
            title: "Spotlight-like Floating Panel",
            content: {
                Form {
                    LabeledContent {
                        Text("⌃ + Space")
                            .monospaced()
                    } label: {
                        Text("Global shortcut")
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
