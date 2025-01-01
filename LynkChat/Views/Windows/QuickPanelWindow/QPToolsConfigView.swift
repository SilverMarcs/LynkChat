//
//  ToolsConfigView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 31/12/2024.
//

import SwiftUI

struct QPToolsConfigView: View {
    @Binding var config: ChatConfig
    
    // Corrected computed property for unified web search binding
    private var webSearchEnabled: Binding<Bool> {
        Binding(
            get: {
                config.isToolEnabled(.webSearch) && config.isToolEnabled(.scrapeLinks)
            },
            set: { newValue in
                if newValue {
                    config.enableTool(.webSearch)
                    config.enableTool(.scrapeLinks)
                } else {
                    config.disableTool(.webSearch)
                    config.disableTool(.scrapeLinks)
                }
            }
        )
    }
    
    var body: some View {
        Toggle("Web", isOn: webSearchEnabled)
        
        Toggle("Image", isOn: Binding(
            get: { config.isToolEnabled(.imageGeneration) },
            set: { newValue in
                if newValue {
                    config.enableTool(.imageGeneration)
                } else {
                    config.disableTool(.imageGeneration)
                }
            }
        ))
        
        Toggle("Transcribe", isOn: Binding(
            get: { config.isToolEnabled(.transcribe) },
            set: { newValue in
                if newValue {
                    config.enableTool(.transcribe)
                } else {
                    config.disableTool(.transcribe)
                }
            }
        ))
    }
}
