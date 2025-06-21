//
//  ToolsToggleView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/06/2025.
//

import SwiftUI

struct SimpleToolsToggleView: View {
    @Binding var config: ChatConfig
    
    var body: some View {
        ControlGroup {
            // Web Search & Scrape Links Toggle
            Toggle(isOn: Binding(
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
            )) {
                Label(Tool.webSearch.shortTitle, systemImage: Tool.webSearch.iconName)
            }
            
            // Image Generation Toggle
            Toggle(isOn: Binding(
                get: {
                    config.isToolEnabled(.imageGeneration)
                },
                set: { newValue in
                    if newValue {
                        config.enableTool(.imageGeneration)
                    } else {
                        config.disableTool(.imageGeneration)
                    }
                }
            )) {
                Label(Tool.imageGeneration.shortTitle, systemImage: Tool.imageGeneration.iconName)
            }
        }
//        .controlGroupStyle(.navigation))
    }
}
