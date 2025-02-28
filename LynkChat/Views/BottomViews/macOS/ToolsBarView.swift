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
        .opacity(0.85)
        #endif
        
        toolButton(
            tool: .imageGeneration,
            isEnabled: config.isToolEnabled(.imageGeneration)
        ) {
            withAnimation(.spring(duration: 0.3)) {
                config.toggleTool(.imageGeneration)
            }
        }
        .scaleEffect(0.95)
        #if os(macOS)
        .opacity(0.8)
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
                .imageScale(.medium)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .foregroundStyle(isEnabled ? tool.color : .secondary)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .circular)
                        .fill(isEnabled ? tool.color.opacity(0.10) : Color.gray.opacity(0.1))
                        .stroke(isEnabled ? tool.color.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                }
                .contentShape(Rectangle())
            #else
                .labelStyle(.iconOnly)
                .foregroundStyle(isEnabled ? tool.color : .secondary)
            #endif
                .symbolEffect(.bounce, value: isEnabled)
        }
        .buttonStyle(.plain)
        #if os(macOS)
        .padding(.horizontal, 2)
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
    chat.config.enabledTools.insert(.processFile)
    
    return InputArea(chat: chat)
        .environment(ChatVM())
        .frame(height: 94)
}

//extension View {
//    @ViewBuilder
//    func labelStyle(includingText: Bool) -> some View {
//        if includingText {
//            self.labelStyle(.titleAndIcon)
//        } else {
//            self.labelStyle(.iconOnly)
//        }
//    }
//}
