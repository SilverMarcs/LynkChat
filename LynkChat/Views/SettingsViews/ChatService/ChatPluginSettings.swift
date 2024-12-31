//
//  ChatPluginSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 14/09/2024.
//

import SwiftUI

struct ChatPluginSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    var body: some View {
        Form {
            Section("Enable for new chats") {
                // custom binding for both config.webSearch and config.scrapeUrls in one togle
                Toggle(isOn: Binding(
                    get: { config.webSearch || config.scrapeLinks },
                    set: { newValue in
                        config.webSearch = newValue
                        config.scrapeLinks = newValue
                    }
                )) {
                    Label("Web Search", systemImage: Tool.webSearch.iconName)
                }
                
                Toggle(isOn: $config.imageGenerate) {
                    Label("Image Generation", systemImage: Tool.imageGeneration.iconName)
                }
                        
                Toggle(isOn: $config.transcribe) {
                    Label("Transcribe", systemImage: Tool.transcribe.iconName)
                }
            
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Plugins")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    ChatPluginSettings()
}
