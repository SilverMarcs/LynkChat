//
//  ChatToolView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI

struct ChatToolView: View {
    var tools: [ToolCall]
    
    var body: some View {
        FlowLayout {
            ForEach(tools) { toolCall in
                ToolButton(toolCall: toolCall)
            }
        }
        .padding(.trailing, -8)
        
        
        ForEach(tools) { toolCall in
            ToolResultView(toolCall: toolCall)
        }
    }
}


