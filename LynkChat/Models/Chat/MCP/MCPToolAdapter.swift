import Foundation

struct MCPCallToolRequest: Codable {
    let jsonrpc: String = "2.0"
    let id: Int
    let method: String = "tools/call"
    let params: Params
    
    struct Params: Codable {
        let name: String
        let arguments: [String: AnyCodable]?
    }
    
    init(id: Int, name: String, arguments: [String: AnyCodable]) {
        self.id = id
        self.params = Params(name: name, arguments: arguments)
    }
}

struct MCPCallToolResponse: Codable {
    struct Result: Codable {
        let content: [MCPToolContent]
        let isError: Bool?
    }
    
    let jsonrpc: String
    let id: Int?
    let result: Result?
    let error: RPCError?
    
    struct RPCError: Codable, Error {
        let code: Int
        let message: String
        let data: [String: AnyCodable]?
    }
}

enum MCPToolContent: Codable {
    case text(String)
    case image(data: String, mimeType: String, metadata: [String: AnyCodable]?)
    case audio(data: String, mimeType: String)
    case resource(uri: String, mimeType: String?, text: String?)
    
    enum CodingKeys: String, CodingKey {
        case type, text, data, mimeType, metadata, uri
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            self = .text(try container.decode(String.self, forKey: .text))
        case "image":
            self = .image(
                data: try container.decode(String.self, forKey: .data),
                mimeType: try container.decode(String.self, forKey: .mimeType),
                metadata: try container.decodeIfPresent([String: AnyCodable].self, forKey: .metadata)
            )
        case "audio":
            self = .audio(
                data: try container.decode(String.self, forKey: .data),
                mimeType: try container.decode(String.self, forKey: .mimeType)
            )
        case "resource":
            self = .resource(
                uri: try container.decode(String.self, forKey: .uri),
                mimeType: try container.decodeIfPresent(String.self, forKey: .mimeType),
                text: try container.decodeIfPresent(String.self, forKey: .text)
            )
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown content type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .image(let data, let mimeType, let metadata):
            try container.encode("image", forKey: .type)
            try container.encode(data, forKey: .data)
            try container.encode(mimeType, forKey: .mimeType)
            try container.encodeIfPresent(metadata, forKey: .metadata)
        case .audio(let data, let mimeType):
            try container.encode("audio", forKey: .type)
            try container.encode(data, forKey: .data)
            try container.encode(mimeType, forKey: .mimeType)
        case .resource(let uri, let mimeType, let text):
            try container.encode("resource", forKey: .type)
            try container.encode(uri, forKey: .uri)
            try container.encodeIfPresent(mimeType, forKey: .mimeType)
            try container.encodeIfPresent(text, forKey: .text)
        }
    }
}

private struct MCPListToolsRequest: Codable {
    let jsonrpc: String = "2.0"
    let id: Int
    let method: String = "tools/list"
    let params: [String: String] = [:]
}

private struct MCPListToolsResponse: Codable {
    struct Result: Codable {
        struct Tool: Codable {
            let name: String
            let description: String?
            let inputSchema: [String: AnyCodable]?
        }
        let tools: [Tool]
        let nextCursor: String?
    }
    let jsonrpc: String
    let id: Int?
    let result: Result?
    let error: RPCError?
    
    struct RPCError: Codable, Error {
        let code: Int
        let message: String
        let data: [String: AnyCodable]?
    }
}

enum MCPToolAdapter {
    static func fetchOpenAITools(enabledServerIds: Set<UUID>) async -> ([ChatCompletionRequest.Tool], [String: MCPServer]) {
        let servers = ChatConfigDefaults().mcpServers.filter {
            enabledServerIds.contains($0.id) && $0.type == .http && $0.isValid
        }
        
        guard !servers.isEmpty else { return ([], [:]) }
        
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
            throw MCPError.invalidServer
        }
        let tools = try await listToolsHTTP(server: server)
        return tools.map { MCPServerTool(name: $0.name, description: $0.description, inputSchema: $0.inputSchema) }
    }
    
    static func callToolHTTP(server: MCPServer, name: String, arguments: [String: AnyCodable]) async throws -> String {
        guard let url = URL(string: server.url) else {
            throw MCPError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/event-stream", forHTTPHeaderField: "Accept")
        
        if let headers = server.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let body = MCPCallToolRequest(id: Int.random(in: 1...1_000_000), name: name, arguments: arguments)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw MCPError.invalidResponse
        }
        
        guard (200...299).contains(http.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw MCPError.httpError(statusCode: http.statusCode, body: errorBody)
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        guard let jsonData = extractSSEData(from: responseString) else {
            throw MCPError.invalidSSEData
        }
        
        let callResponse = try JSONDecoder().decode(MCPCallToolResponse.self, from: jsonData)
        
        if let error = callResponse.error {
            throw MCPError.rpcError(code: error.code, message: error.message)
        }
        
        if let result = callResponse.result {
            let resultData = try JSONEncoder().encode(result)
            return String(data: resultData, encoding: .utf8) ?? "{}"
        }
        
        return "{}"
    }
    
    private static func listToolsHTTP(server: MCPServer) async throws -> [MCPListToolsResponse.Result.Tool] {
        guard let url = URL(string: server.url) else {
            throw MCPError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/event-stream", forHTTPHeaderField: "Accept")
        
        if let headers = server.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let body = MCPListToolsRequest(id: Int.random(in: 1...1_000_000))
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw MCPError.invalidResponse
        }
        
        guard (200...299).contains(http.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw MCPError.httpError(statusCode: http.statusCode, body: errorBody)
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        guard let jsonData = extractSSEData(from: responseString) else {
            throw MCPError.invalidSSEData
        }
        
        let listResponse = try JSONDecoder().decode(MCPListToolsResponse.self, from: jsonData)
        
        if let error = listResponse.error {
            throw MCPError.rpcError(code: error.code, message: error.message)
        }
        
        return listResponse.result?.tools ?? []
    }
    
    private static func extractSSEData(from response: String) -> Data? {
        for line in response.components(separatedBy: .newlines) {
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6))
                return jsonString.data(using: .utf8)
            }
        }
        return nil
    }
    
    private static func sanitizeName(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
        let filtered = name.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" }.reduce("") { $0 + String($1) }
        return String(filtered.prefix(64))
    }
}

enum MCPError: Error, LocalizedError {
    case invalidServer
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, body: String)
    case invalidSSEData
    case rpcError(code: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidServer: "Invalid server configuration"
        case .invalidURL: "Invalid server URL"
        case .invalidResponse: "Invalid server response"
        case .httpError(let code, let body): "HTTP \(code): \(body)"
        case .invalidSSEData: "No valid data in response"
        case .rpcError(_, let message): message
        }
    }
}
