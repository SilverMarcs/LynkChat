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

        case .scrapeLinks:
            EmptyView()
        case .transcribe:
            GroupBox {
                Group {
                    if let result = chatTool.result {
                        ToolTranscribeView(transcription: result)
                    } else {
                        ToolTranscribePlaceholderView()
                    }
                }
                .padding(3)
            }
            .groupBoxStyle(PlatformGroupBoxStyle())
            .animation(.easeInOut(duration: 0.3), value: chatTool.result != nil)
        }
    }
}

#Preview {
    @Previewable @State var chatTool1: ChatTool = .mockGoogleTool2
    
    @Previewable @State var chatTool2: ChatTool = .mockTranscribeTool
    
    VStack {
        ToolResultView(chatTool: chatTool1)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    chatTool1.result = String.mockGoogleSearch
                }
            }
        
        ToolResultView(chatTool: chatTool2)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    chatTool2.result = String.mockTranscription + "\n" + String.mockTranscription
                }
            }
    }
    .padding()
    .frame(width: 700, height: 300)
}
