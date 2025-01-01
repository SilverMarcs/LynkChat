//
//  ChatToolView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI

struct ChatToolView: View {
    var tools: [ChatTool]
    
    var body: some View {
        HStack {
            ForEach(tools) { chatTool in
                ToolButton(chatTool: chatTool)
                    .transaction { $0.animation = nil }
            }
        }
        
        
        ForEach(tools) { chatTool in
            ToolResultView(chatTool: chatTool)
                .transaction { $0.animation = nil }
        }
    }
}

#Preview {
    ChatToolView(tools: [.mockTool, .mockImageTool])
        .frame(width: 400, height: 400)
}


