//
//  ToolsBarView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 22/12/2024.
//
//

import SwiftUI

struct ToolsBarView: View {
    @Binding var config: ChatConfig
    
    var body: some View {
        toolButton(
            tool: .webSearch, // Using webSearch as the display tool
            isEnabled: config.isToolEnabled(.webSearch) || config.isToolEnabled(.scrapeLinks)
        ) {
            config.toggleTool(.webSearch)
            config.toggleTool(.scrapeLinks)
        }
        .opacity((config.isToolEnabled(.webSearch) || config.isToolEnabled(.scrapeLinks) ? 0.85 : 0.8))
        
        toolButton(
            tool: .imageGeneration,
            isEnabled: config.isToolEnabled(.imageGeneration)
        ) {
            config.toggleTool(.imageGeneration)
        }
        .opacity(config.isToolEnabled(.imageGeneration) ? 0.6 : 0.7)
    }
    
    @ViewBuilder
    private func toolButton(
        tool: Tool,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(tool.shortTitle, systemImage: tool.iconName)
                .imageScale(isEnabled ? .medium : .large)
                .padding(.horizontal, isEnabled ? 7 : 2)
                .padding(.vertical, isEnabled ? 3 : 0)
                .foregroundStyle(isEnabled ? tool.color : .secondary)
                .background {
                    if isEnabled {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(tool.color.opacity(0.10))
                    }
                }
                .contentShape(Rectangle())
                .apply {
                    if isEnabled {
                        $0.labelStyle(.titleAndIcon)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(tool.color.opacity(0.3), lineWidth: 1)
                            }
                    } else {
                        $0.labelStyle(.iconOnly)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, isEnabled ? 1 : 5)
        
        var imageSize: CGFloat {
            if isEnabled {
                return 14
            } else {
                return 17
            }
        }
    }
}

#Preview {
    InputArea(chat: Chat())
        .environment(ChatVM())
        .frame(height: 94)
}
