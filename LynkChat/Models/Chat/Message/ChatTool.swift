//
//  ChatTool.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import Foundation

struct ChatTool: Identifiable, Codable {
    let toolCallId: String
    let toolName: String
    let args: String
    var result: String?
    
    var id: String {
        toolCallId
    }
    
    init(toolCallId: String, toolName: String, args: String, result: String? = nil) {
        self.toolCallId = toolCallId
        self.toolName = toolName
        self.args = args
        self.result = result
    }
}
