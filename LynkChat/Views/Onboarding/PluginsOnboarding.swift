//
//  PluginsOnboarding 2.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct PluginsOnboarding: View {
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    var body: some View {
        GenericOnboardingView(
            icon: "puzzlepiece.extension.fill",
            iconColor: .cyan,
            title: "Connect LLMs with plugins",
            content: {
                Form {
                    Section {
                        Text("Setup MCP Servers")
                    }
                    #if os(iOS)
                    .listRowBackground(Color(.secondarySystemBackground))
                    #endif
                }
            },
            footerText: "Enable plugins to give your AI assistant more capabilities"
        )
    }
}

#Preview {
    PluginsOnboarding()
        .frame(width: 500, height: 500)
}
