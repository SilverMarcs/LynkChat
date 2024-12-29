//
//  PluginsOnboarding 2.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct PluginsOnboarding: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    var body: some View {
        GenericOnboardingView(
            icon: "hammer.fill",
            iconColor: .cyan,
            title: "Connect LLMs with plugins",
            content: {
                Form {
                    Section {
                        // custom binding that controls both config.webTools and config.scrapeLinks
                        Toggle("Web Search", isOn: Binding(
                            get: { config.webSearch || config.scrapeLinks },
                            set: { newValue in
                                config.webSearch = newValue
                                config.scrapeLinks = newValue
                            }
                        ))
                        Toggle("Image Generate", isOn: $config.imageGenerate)
                        Toggle("Transcribe", isOn: $config.transcribe)
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
