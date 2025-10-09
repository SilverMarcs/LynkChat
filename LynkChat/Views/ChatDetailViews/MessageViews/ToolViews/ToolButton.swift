//
//  ToolButton.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolButton: View {
    var toolCall: ToolCall
    
    @State private var showArguments = false
    
    var body: some View {
        Button {
            showArguments.toggle()
        } label: {
            Label(toolCall.tool.title, systemImage: toolCall.tool.iconName)
                .fontWeight(.semibold)
                .foregroundStyle(toolCall.tool.color)
        }
        .labelStyle(.titleAndIcon)
        .buttonStyle(.bordered)
        #if os(macOS)
        .controlSize(.large)
        #endif
        .buttonBorderShape(.roundedRectangle)
        .popover(isPresented: $showArguments) {
            ScrollView {
                NativeMarkdownView(text: toolCall.result?.text ?? toolCall.arguments)
                    .textSelection(.enabled)
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium])
            .contentMargins(20, for: .scrollContent)
            .frame(maxWidth: 500, maxHeight: 500)
        }
    }
    
}

#Preview {
    ToolButton(toolCall: ToolCall(id: "test", tool: .generateImage, arguments: "Test prompt"))
}
