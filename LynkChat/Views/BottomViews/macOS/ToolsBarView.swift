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
        #if os(macOS)
        .opacity((config.isToolEnabled(.webSearch) || config.isToolEnabled(.scrapeLinks) ? 0.85 : 0.9))
        #endif
        
        toolButton(
            tool: .imageGeneration,
            isEnabled: config.isToolEnabled(.imageGeneration)
        ) {
            withAnimation(.spring(duration: 0.3)) {
                config.toggleTool(.imageGeneration)
            }
        }
        .scaleEffect(config.isToolEnabled(.imageGeneration) ? 0.95 : 0.9)
        #if os(macOS)
        .opacity(config.isToolEnabled(.imageGeneration) ? 0.8 : 0.9)
        #endif
        
        toolButton(
            tool: .transcribe,
            isEnabled: config.isToolEnabled(.transcribe)
        ) {
            withAnimation(.spring(duration: 0.3)) {
                config.toggleTool(.transcribe)
            }
        }
        .apply {
            if config.isToolEnabled(.transcribe) {
                $0.popoverTip(AudioUploadingTip())
            } else {
                $0
            }
        }
        #if os(macOS)
        .opacity(config.isToolEnabled(.transcribe) ? 0.8 : 0.9)
        #endif
    }
    
    @ViewBuilder
    private func toolButton(
        tool: Tool,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(tool.shortTitle, systemImage: tool.iconName)
            #if os(macOS)
                .imageScale(isEnabled ? .medium : .large)
                .padding(.horizontal, isEnabled ? 7 : 2)
                .padding(.vertical, isEnabled ? 3 : 0)
                .foregroundStyle(isEnabled ? tool.color : .secondary)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .circular)
                        .fill(isEnabled ? tool.color.opacity(0.10) : .clear)
                        .stroke(isEnabled ? tool.color.opacity(0.3) : .clear, lineWidth: 1)
                }
                .labelStyle(includingText: isEnabled)
                .contentShape(Rectangle())
            #else
                .labelStyle(.iconOnly)
                .foregroundStyle(isEnabled ? tool.color : .secondary)
            #endif
        }
        .buttonStyle(.plain)
        #if os(macOS)
        .padding(.horizontal, isEnabled ? 2 : 5)
        #else
        .padding(.horizontal, 5)
        #endif
    }
}

#Preview {
    let chat = Chat()
    chat.config.enabledTools.insert(.webSearch)
    chat.config.enabledTools.insert(.scrapeLinks)
    chat.config.enabledTools.insert(.imageGeneration)
    chat.config.enabledTools.insert(.transcribe)
    
    return InputArea(chat: chat)
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
