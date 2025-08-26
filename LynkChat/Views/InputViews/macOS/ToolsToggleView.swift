//
//  ToolsToggleView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/06/2025.
//

import SwiftUI

struct ToolsToggleView: View {
    @Binding var config: ChatConfig
    
    var body: some View {
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
            Label(Tool.webSearch.title, systemImage: Tool.webSearch.iconName)
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
            Label(Tool.imageGeneration.title, systemImage: Tool.imageGeneration.iconName)
        }
        
        Toggle(isOn: Binding(
            get: {
                config.isToolEnabled(.rag)
            },
            set: { newValue in
                if newValue {
                    config.enableTool(.rag)
                } else {
                    config.disableTool(.rag)
                }
            }
        )) {
            Label(Tool.rag.title, systemImage: Tool.rag.iconName)
        }
    }
}
