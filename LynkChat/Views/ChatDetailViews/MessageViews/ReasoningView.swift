//
//  ReasoningView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/02/2025.
//

import SwiftUI

struct ReasoningView: View {
    @Environment(\.chat) var chat
    let reason: String
    let tool: ChatTool
    
    init(reason: String) {
        self.reason = reason
        self.tool = ChatTool(toolCallId: UUID().uuidString, tool: .reasoning, args: reason, result: "reason")
    }
    
    var body: some View {
        ToolButton(chatTool: tool, skipPrettyPrinting: true)
        
//        GroupBox {
//            VStack(alignment: .leading) {
//                HStack {
//                    Text("Reasoning")
//                        .font(.headline)
//                        .shimmerWithoutRedact(when: chat.isReasoning)
//                        .padding(.leading, 3)
//                    
//                    Spacer()
//                    
//                    Button {
//                        showingReasoning.toggle()
//                    } label: {
//                        Text(showingReasoning ? "Collapse" : "Expand")
//                    }
//                }
//                
//                
//                if showingReasoning {
//                    Divider()
//                    
//                    ScrollView {
//                        Text(LocalizedStringKey(reason))
//                            .foregroundStyle(.secondary)
//                            .textSelection(.enabled)
//                    }
//                    .frame(maxHeight: 500)
//                    .contentMargins(5)
//                }
//            }
//        }
//        .groupBoxStyle(PlatformGroupBox(radius: 15))
//        .transaction { $0.animation = nil }
    }
}

#Preview {
    ReasoningView(reason: String.markdownContent)
}
