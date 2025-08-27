//
//  ReasoningView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/02/2025.
//

import SwiftUI

struct ReasoningView: View {
    @Environment(\.chat) var chat
    let reason: String
    let tool: ChatTool
    
    init(reason: String) {
        self.reason = reason
        self.tool = ChatTool(toolCallId: UUID().uuidString, tool: .reasoning, args: reason, result: "reason")
    }
    
    var body: some View {
        ToolButton(chatTool: tool)
    }
}

#Preview {
    ReasoningView(reason: String.markdownContent)
}
