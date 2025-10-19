//
//  MCPServer.swift
//  LynkChat
//
//  Created by Zabir Raihan on 11/10/2025.
//

import Foundation

struct MCPServer: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var type: MCPServerType
    var url: String
    var headers: [String: String]?
    var tools: [MCPServerTool]
    var isEnabled: Bool = true
    enum MCPServerType: String, Codable, CaseIterable {
        case http = "http"
        var displayName: String { "HTTP" }
    }
    
    init(id: UUID = UUID(), name: String, type: MCPServerType = .http, url: String, headers: [String: String]? = nil, tools: [MCPServerTool] = [], isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.type = type
        self.url = url
        self.headers = headers
        self.tools = tools
        self.isEnabled = isEnabled
    }
    
    var isValid: Bool {
        !url.isEmpty
    }
}
