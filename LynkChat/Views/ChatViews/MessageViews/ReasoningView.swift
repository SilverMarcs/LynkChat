//
//  ReasoningView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/02/2025.
//

import SwiftUI

struct ReasoningView: View {
    let reason: String
    
    @State private var showArguments = false
    
    var body: some View {
        Button {
            showArguments.toggle()
        } label: {
            Label("Reasoning", systemImage: "circle.hexagonpath")
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
        }
        .labelStyle(.titleAndIcon)
        .buttonStyle(.bordered)
        #if os(macOS)
        .controlSize(.large)
        #endif
        .buttonBorderShape(.roundedRectangle)
        .popover(isPresented: $showArguments) {
            ScrollView {
                NativeMarkdownView(text: reason)
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

#Preview {
    ReasoningView(reason: String.markdownContent)
}
