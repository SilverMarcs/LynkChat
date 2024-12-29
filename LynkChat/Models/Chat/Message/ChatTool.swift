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
    var result: String?
    
    var id: String {
        toolCallId
    }
    
    // mutating func to change the result
    mutating func setResult(_ newResult: String) {
        self.result = newResult
    }
}
