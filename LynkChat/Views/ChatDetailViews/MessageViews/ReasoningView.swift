//
//  ReasoningView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/02/2025.
//

import SwiftUI

struct ReasoningView: View {
    let reason: String
    @State private var showReasoning = false
    
    var body: some View {
        Button {
            showReasoning.toggle()
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
        .popover(isPresented: $showReasoning) {
            ScrollView {
                NativeMarkdownView(text: reason)
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
    ReasoningView(reason: String.markdownContent)
}

