import Foundation

enum MCPToolAdapter {
    static func fetchOpenAITools(servers: [MCPServer]) async -> ([ChatCompletionRequest.Tool], [String: MCPServer]) {
        var allTools: [ChatCompletionRequest.Tool] = []
        var toolToServer: [String: MCPServer] = [:]
        
        for server in servers {
            let cachedTools = server.tools
            
            let openAITools = cachedTools.map { t in
                ChatCompletionRequest.Tool(
                    type: "function",
                    function: .init(
                        name: sanitizeName(t.name),
                        description: t.description,
                        parameters: t.inputSchema
                    )
                )
            }
            
            allTools.append(contentsOf: openAITools)
            for tool in cachedTools {
                toolToServer[sanitizeName(tool.name)] = server
            }
        }
        
        var seen = Set<String>()
        let deduped = allTools.filter { tool in
            let name = tool.function.name
            guard !seen.contains(name) else { return false }
            seen.insert(name)
            return true
        }
        
        return (deduped, toolToServer.filter { seen.contains($0.key) })
    }
    
    static func listToolsForServer(server: MCPServer) async throws -> [MCPServerTool] {
        guard server.type == .http && server.isValid else {
            throw RuntimeError("Invalid server configuration")
        }
        let tools = try await MCPHTTPClient.listToolsHTTP(server: server)
        return tools.map { MCPServerTool(name: $0.name, description: $0.description, inputSchema: $0.inputSchema) }
    }
    
    static func callToolHTTP(server: MCPServer, name: String, arguments: [String: AnyCodable]) async throws -> String {
        try await MCPHTTPClient.callToolHTTP(server: server, name: name, arguments: arguments)
    }
    
    private static func sanitizeName(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
        let filtered = name.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" }.reduce("") { $0 + String($1) }
        return String(filtered.prefix(64))
    }
}

