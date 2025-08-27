//
//  ChatTool.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import Foundation

struct ChatTool: Identifiable, Codable {
    let toolCallId: String
    let tool: Tool
    let args: String
    var result: ToolResult?
    
    var id: String {
        toolCallId
    }
}
