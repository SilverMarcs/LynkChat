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
//                        HStack {
//                            Label("Web Search", systemImage: Tool.webSearch.iconName)
//                            if horizontalSize != .compact {
//                                Spacer()
//                                Text("Access up-to-date information")
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                        
//                        HStack {
//                            Label("Image Generate", systemImage: Tool.imageGeneration.iconName)
//                            if horizontalSize != .compact {
//                                Spacer()
//                                Text("Generate images from text")
//                                    .foregroundColor(.secondary)
//                            }
//                        }
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
