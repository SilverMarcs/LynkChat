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
            tool: .webSearch,
            isEnabled: config.isToolEnabled(.webSearch) || config.isToolEnabled(.scrapeLinks)
        ) {
            withAnimation(.spring(duration: 0.3)) {
                config.toggleTool(.webSearch)
                config.toggleTool(.scrapeLinks)
            }
        }
        .opacity((config.isToolEnabled(.webSearch) || config.isToolEnabled(.scrapeLinks) ? 0.85 : 0.8))
        .padding(.leading, (config.isToolEnabled(.webSearch) || config.isToolEnabled(.scrapeLinks) ? -4 : 0))
        
        toolButton(
            tool: .imageGeneration,
            isEnabled: config.isToolEnabled(.imageGeneration)
        ) {
            withAnimation(.spring(duration: 0.3)) {
                config.toggleTool(.imageGeneration)
            }
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
                .padding(.vertical, isEnabled ? 3.5 : 0)
                .foregroundStyle(isEnabled ? tool.color : .secondary)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isEnabled ? tool.color.opacity(0.10) : .clear)
                        .stroke(isEnabled ? tool.color.opacity(0.3) : .clear, lineWidth: 1)
                }
                .labelStyle(includingText: isEnabled)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, isEnabled ? 2 : 5)
    }
}

#Preview {
    InputArea(chat: Chat())
        .environment(ChatVM())
        .frame(height: 94)
}

extension View {
    @ViewBuilder
    func labelStyle(includingText: Bool) -> some View {
        if includingText {
            self.labelStyle(.titleAndIcon)
        } else {
            self.labelStyle(.iconOnly)
        }
    }
}
