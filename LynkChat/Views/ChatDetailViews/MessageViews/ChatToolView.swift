//
//  ChatToolView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI

struct ChatToolView: View {
    var chatTool: ChatTool
    @State private var showArguments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Button {
                withAnimation {
                    showArguments.toggle()
                }
            } label: {
                GroupBox {
                    HStack(spacing: 4) {
                        Text("Used")
                            .foregroundStyle(.secondary)
                        
//                        Group {
//                            Text(chatTool.tool.title)
//                                .fontWeight(.semibold)
//                            
//                            Image(systemName: chatTool.tool.iconName)
//                        }
//                        .foregroundStyle(chatTool.tool.color)
//                        .opacity(0.9)
                        Text("\(chatTool.tool.title) \(Image(systemName: chatTool.tool.iconName))")
                            .fontWeight(.semibold)
                            .foregroundStyle(chatTool.tool.color)
                            .opacity(0.9)
                            
                    }
                    .padding(3)
                }
                .groupBoxStyle(PlatformGroupBoxStyle())
            }
            .transaction { $0.animation = nil }
            .buttonStyle(.plain)

            if showArguments {
                HStack(alignment: .center, spacing: 10) {
                    Rectangle()
                        .fill(.tertiary)
                        .frame(width: 2)
                
                    Text(chatTool.args)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .monospaced()
                }
                .padding(.vertical, 5)
            }
            
            if showArguments, let result = chatTool.result {
                chatTool.tool.resultView(result)
            }
        }
    }
}

#Preview {
    ChatToolView(chatTool: .mockTool)
        .frame(width: 200, height: 100)
}


