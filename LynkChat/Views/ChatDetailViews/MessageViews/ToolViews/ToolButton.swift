//
//  ToolButton.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolButton: View {
    var chatTool: ChatTool
    
    @State private var showArguments = false
    
    var body: some View {
        Button {
            showArguments.toggle()
        } label: {
            Label(chatTool.tool.title, systemImage: chatTool.tool.iconName)
                .fontWeight(.semibold)
                .foregroundStyle(chatTool.tool.color)
        }
        .labelStyle(.titleAndIcon)
        .buttonStyle(.bordered)
        #if os(macOS)
        .controlSize(.large)
        #endif
        .buttonBorderShape(.roundedRectangle)
        .popover(isPresented: $showArguments) {
            ScrollView {
//                Text(try! AttributedString(markdown: chatTool.args))
                NativeMarkdownView(text: chatTool.result?.textContent ?? chatTool.args)
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
    ToolButton(chatTool: .mockTool)
}
