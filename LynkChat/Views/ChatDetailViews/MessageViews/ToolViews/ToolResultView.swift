//
//  ToolResultView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolResultView: View {
    let chatTool: ChatTool
    @ObservedObject var config = AppConfig.shared
    
    var body: some View {
        if config.showUrlParsingResult {
            Text(chatTool.result ?? "No result available")
                .textSelection(.enabled)
        } else {
            // Show specialized views when config is false
            switch chatTool.tool {
            case .scrapeLinks:
                EmptyView()
            case .imageGeneration:
                ToolImageView(urlStr: chatTool.result)
            case .webSearch:
                ToolSearchResultView(searchString: chatTool.result)
            case .processFile:
                FileProcessingView(content: chatTool.result)
            }
        }
    }
}

#Preview {
    @Previewable @State var chatTool1: ChatTool = .mockGoogleTool2
    
    @Previewable @State var chatTool2: ChatTool = .mockTranscribeTool
    
    VStack {
        ToolResultView(chatTool: chatTool1)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    chatTool1.result = String.mockTavilyThorough
                }
            }
        
        ToolResultView(chatTool: chatTool2)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    chatTool2.result = String.mockTranscription + "\n" + String.mockTranscription
                }
            }
    }
    .padding()
    .frame(width: 700, height: 300)
}
