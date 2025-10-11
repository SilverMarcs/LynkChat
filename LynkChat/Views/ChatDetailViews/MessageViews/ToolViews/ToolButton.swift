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
            Label(chatTool.toolName, systemImage: "puzzlepiece")
                .fontWeight(.semibold)
                .foregroundStyle(.green)
        }
        .labelStyle(.titleAndIcon)
        .buttonStyle(.bordered)
        #if os(macOS)
        .controlSize(.large)
        #endif
        .buttonBorderShape(.roundedRectangle)
        .popover(isPresented: $showArguments) {
            ScrollView {
                NativeMarkdownView(text: chatTool.result ?? chatTool.args)
                    .textSelection(.enabled)
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium])
            .contentMargins(20, for: .scrollContent)
            #if os(macOS)
            .frame(width: 500, height: 500)
            #endif
        }
    }
}
