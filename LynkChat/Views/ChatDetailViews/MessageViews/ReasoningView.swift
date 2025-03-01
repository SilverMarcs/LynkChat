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
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(Color.gray.opacity(0.1))
            
            ScrollView {
                Text(String(reason.dropFirst()))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .padding(10)
            }
            .frame(maxHeight: showingReasoning ? 300 : 100)
        }
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.gray.opacity(0.05))
                .strokeBorder(.quaternary, lineWidth: 1)
        }
        .cornerRadius(8)
        .transaction { $0.animation = nil }
    }
}

#Preview {
    ReasoningView(reason: String.markdownContent)
}
