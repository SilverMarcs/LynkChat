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
                ProgressView()
                    .frame(width: 300, height: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.background.quinary)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
        default:
            if let result = chatTool.result {
                Text("Result: \(result)")
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
