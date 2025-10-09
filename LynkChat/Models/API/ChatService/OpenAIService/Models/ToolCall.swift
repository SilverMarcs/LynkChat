//
//  ToolCall.swift
//  SwiftAI
//
//  Created by Zabir Raihan on 06/10/2025.
//

import Foundation

struct ToolCall: Identifiable, Equatable, Hashable, Codable {
    let id: String
    let tool: Tool
    let arguments: String
    var result: Result?
    
    init(id: String, tool: Tool, arguments: String, result: Result? = nil) {
        self.id = id
        self.tool = tool
        self.arguments = arguments
        self.result = result
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ToolCall, rhs: ToolCall) -> Bool {
        lhs.id == rhs.id
    }
    
    struct Result: Codable {
        let text: String
        let data: [Data]
        
        init(text: String, data: [Data] = []) {
            self.text = text
            self.data = data
        }
    }
}

