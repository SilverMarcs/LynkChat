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
        switch chatTool.result {
        case .scrapeLinks:
            EmptyView()
        case .imageGeneration(let imageGenResult):
            ToolImageView(imageResult: imageGenResult)
        case .webSearch(let searchResult):
            ToolSearchResultView(searchResult: searchResult)
        case .rag(let ragResponse):
            ToolRagView(ragResponse: ragResponse)
        case .processFile(let content), .reasoning(let content):
            FileProcessingView(content: content)
        case .mcp(let content):
            Text(content)
        case .none:
            EmptyView()
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
                    // Create SearchResult from mock data
                    if let data = String.mockTavilyThorough.data(using: .utf8),
                       let searchResult = try? JSONDecoder().decode(SearchResult.self, from: data) {
                        chatTool1.result = .webSearch(searchResult)
                    }
                }
            }
        
        ToolResultView(chatTool: chatTool2)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    chatTool2.result = .processFile(String.mockTranscription + "\n" + String.mockTranscription)
                }
            }
    }
    .padding()
    .frame(width: 700, height: 300)
}
