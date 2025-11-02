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
        FlowLayout {
            ForEach(tools) { chatTool in
                ToolButton(chatTool: chatTool)
            }
        }
        .padding(.trailing, -8)
        
        
        ForEach(tools) { chatTool in
            ToolResultView(chatTool: chatTool)
        }
    }
}


