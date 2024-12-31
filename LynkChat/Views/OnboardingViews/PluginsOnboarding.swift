//
//  PluginsOnboarding 2.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct PluginsOnboarding: View {
    var body: some View {
        GenericOnboardingView(
            icon: "hammer.fill",
            iconColor: .cyan,
            title: "Connect LLMs with plugins",
            content: {
                Form {
                    Section {
                        HStack {
                            Text("Web Search")
                            Image(systemName: Tool.webSearch.iconName)
                        }
                        
                        HStack {
                            Text("Image Generate")
                            Image(systemName: Tool.imageGeneration.iconName)
                        }
                        
                        HStack {
                            Text("Transcribe")
                            Image(systemName: Tool.transcribe.iconName)
                        }
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
