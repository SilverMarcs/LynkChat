//
//  ToolResultView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolResultView: View {
    let chatTool: ChatTool
    
    var body: some View {
        switch chatTool.tool {
        case .imageGeneration:
            if let result = chatTool.result {
                ToolImageView(urlStr: result)
            } else {
                ToolImagePlaceholderView()
            }
        case .webSearch:
            ZStack {
                if let result = chatTool.result {
                    ToolSearchView(searchString: result)
                        .transition(.opacity)
                } else {
                    ToolSearchPlaceholderView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: chatTool.result != nil)
            .frame(height: 66) // Set a fixed frame that matches both views

        default:
            if let result = chatTool.result {
                Text("Result: \(result)")
                    .textSelection(.enabled)
            } else {
                // Generic placeholder for other tools
                HStack {
                    ProgressView()
                    Text("Processing \(chatTool.tool.rawValue)...")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.background.quaternary)
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var chatTool: ChatTool = .mockGoogleTool2
    
    ToolResultView(chatTool: chatTool)
        .frame(width: 700)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                chatTool.result = String.mockGoogleSearch
            }
        }
}
