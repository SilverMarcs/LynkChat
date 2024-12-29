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
        HStack(spacing: 8) {
            ForEach(Tool.allCases, id: \.self) { tool in
                toolButton(
                    tool: tool,
                    isEnabled: config.isToolEnabled(tool)
                ) {
                    config.toggleTool(tool)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
    
    @ViewBuilder
    private func toolButton(
        tool: Tool,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: tool.iconName)
                    .imageScale(.medium)
                
                if isEnabled {
                    Text(tool.title)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
//            .border(.red)
            .foregroundStyle(isEnabled ? tool.color : Color.secondary)
            .background {
                if isEnabled {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(tool.color.opacity(0.15))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.3), value: isEnabled)
    }
}

// Preview
#Preview {
//    @Previewable @State var config = ChatConfig()
    
//    ToolsBarView(config: $config)
//        .padding()
    InputArea(chat: Chat())
        .environment(ChatVM())
}
