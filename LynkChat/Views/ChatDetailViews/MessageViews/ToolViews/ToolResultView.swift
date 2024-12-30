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

        case .scrapeLinks:
            EmptyView()
        case .transcribe:
            // TODO: do htis
            GroupBox {
                if let result = chatTool.result {
                    Text(result)
                        .font(.callout)
                        .lineLimit(3)
                        .truncationMode(.tail)
                } else {
                    ProgressView()
                }
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
