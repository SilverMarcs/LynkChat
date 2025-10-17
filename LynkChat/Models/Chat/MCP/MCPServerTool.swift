//
//  MCPServerTool.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/10/2025.
//

import Foundation

struct MCPServerTool: Codable, Hashable {
    static func == (lhs: MCPServerTool, rhs: MCPServerTool) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: UUID = UUID()
    let name: String
    let description: String?
    let inputSchema: [String: AnyCodable]?
}
