//
//  ReasoningView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/02/2025.
//

import SwiftUI

struct ReasoningView: View {
    let reason: String
    
    @State private var showingReasoning = false
    
    var body: some View {
        let trimmedReason = reason.hasPrefix("\n") ? String(reason.dropFirst()) : reason
        
        VStack(alignment: .leading, spacing: 0) {
            // This header will be sticky
            HStack {
                Text("Reasoning")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    showingReasoning.toggle()
                } label: {
                    Text(showingReasoning ? "Collapse" : "Expand")
                        .font(.footnote)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.1))
            .zIndex(1) // Ensures it stays on top
            
            if showingReasoning {
                ScrollView {
                    Text(trimmedReason)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .padding(12)
                        .padding(.top, 0)
                }
                .frame(maxHeight: 300)
            } else {
                Text(trimmedReason.prefix(500) + (trimmedReason.count > 500 ? "..." : ""))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .padding(12)
                    .padding(.top, 0)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.gray.opacity(0.05))
                .strokeBorder(.quaternary, lineWidth: 1)
        }
        .cornerRadius(8)
    }
}
