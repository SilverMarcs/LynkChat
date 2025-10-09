//
//  ToolResultView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolResultView: View {
    let toolCall: ToolCall
    
    var body: some View {
        if let result = toolCall.result {
            // Display images if data is present
            if !result.data.isEmpty {
                ToolImageGridView(imageDatas: result.data)
            }
        } else {
            // Show placeholder for image tools
            switch toolCall.tool {
            case .generateImage, .editImage:
                ToolImageGridView(imageDatas: [])
            }
        }
    }
}

// Helper view for displaying images in a grid
struct ToolImageGridView: View {
    let imageDatas: [Data]
    
    var body: some View {
        if imageDatas.isEmpty {
            // Placeholder
            EmptyView()
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 10) {
                ForEach(Array(imageDatas.enumerated()), id: \.offset) { index, data in
                    #if os(macOS)
                    if let nsImage = NSImage(data: data) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                    }
                    #else
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                    }
                    #endif
                }
            }
            .padding()
        }
    }
}

#Preview {
    ToolResultView(toolCall: ToolCall(id: "test", tool: .generateImage, arguments: "Test prompt"))
        .padding()
        .frame(width: 700, height: 300)
}
