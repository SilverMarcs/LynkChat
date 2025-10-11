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
    
    // For HTTP type
    var url: String
    var headers: [String: String]?
    
    enum MCPServerType: String, Codable, CaseIterable {
        case http = "http"
        
        var displayName: String {
            switch self {
            case .http: return "HTTP"
            }
        }
    }
    
    // HTTP initializer
    init(name: String, type: MCPServerType = .http,  url: String, headers: [String: String]? = nil) {
        self.name = name
        self.type = .http
        self.url = url
        self.headers = headers
    }
    
    // Convert to JSON format expected by the API
    func toJSONObject() -> [String: Any] {
        var jsonObject: [String: Any] = [
            "type": type.rawValue
        ]
        
        switch type {
        case .http:
            jsonObject["url"] = url
            if let headers = headers, !headers.isEmpty {
                jsonObject["headers"] = headers
            }
        }
        
        return jsonObject
    }
    
    // Validation
    var isValid: Bool {
        switch type {
        case .http:
            !url.isEmpty
        }
    }
    
    // Static examples
    static let examples: [MCPServer] = [
        MCPServer(
            name: "sosumi",
            url: "https://sosumi.ai/mcp",
        ),
        MCPServer(
            name: "context7",
            url: "https://mcp.context7.com/mcp",
            headers: ["CONTEXT7_API_KEY": "YOUR_CONTEXT7_API_KEY"]
        )
    ]
}

// Helper to convert array of MCPServers to dictionary
extension Array where Element == MCPServer {
    func toDictionary(enabledIds: Set<UUID>) -> [String: [String: Any]]? {
        let enabledServers = self.filter { enabledIds.contains($0.id) && $0.isValid }
        
        guard !enabledServers.isEmpty else {
            return nil
        }
        
        var serversDict: [String: [String: Any]] = [:]
        for server in enabledServers {
            serversDict[server.name] = server.toJSONObject()
        }
        
        return serversDict
    }
    
    static func fromJSONString(_ jsonString: String) -> [MCPServer] {
        guard let jsonData = jsonString.data(using: .utf8),
              let serversDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: [String: Any]] else {
            return []
        }
        
        var servers: [MCPServer] = []
        
        for (name, config) in serversDict {
            guard let typeString = config["type"] as? String,
                  let type = MCPServer.MCPServerType(rawValue: typeString),
                  let url = config["url"] as? String
            else {
                
                continue
            }
            
            var server = MCPServer(name: name, type: type, url: url)
            
            switch type {
            case .http:
                server.url = config["url"] as! String
                server.headers = config["headers"] as? [String: String]
            }
            
            servers.append(server)
        }
        
        return servers
    }
}
