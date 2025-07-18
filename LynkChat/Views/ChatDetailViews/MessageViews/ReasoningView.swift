//
//  ReasoningView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/02/2025.
//

import SwiftUI

struct ReasoningView: View {
    let reason: String
    
    @State private var showingReasoning = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Reasoning")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    showingReasoning.toggle()
                } label: {
                    Text(showingReasoning ? "Collapse" : "Expand")
                }
            }
            .padding(8)
            .background(.background.tertiary.opacity(0.6))
            
            ScrollView {
                Text(String(reason))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .padding(10)
            }
            .frame(maxHeight: showingReasoning ? 300 : 100)
        }
        .background(.background.secondary)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        )
        .transaction { $0.animation = nil }
    }
}

#Preview {
    ReasoningView(reason: String.markdownContent)
}
