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
        GroupBox {
            VStack {
                HStack {
                    Text("Reasoning")
                        .font(.title3.bold())
                    
                    Spacer()
                    
                    Button {
                        showingReasoning.toggle()
                    } label: {
                        Text(showingReasoning ? "Collapse" : "Expand")
                    }
                }
                
                if showingReasoning {
                    Divider()
                    
                    ScrollView {
                        Text(LocalizedStringKey(reason))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding(5)
        }
        .transaction { $0.animation = nil }
    }
}

#Preview {
    ReasoningView(reason: String.markdownContent)
}
