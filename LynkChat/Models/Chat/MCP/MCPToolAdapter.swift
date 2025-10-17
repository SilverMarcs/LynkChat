//
//  MCPToolAdapter.swift
//  LynkChat
//
//  Simple MCP→OpenAI tools adapter over HTTP transport.
//

import Foundation

// MARK: - Minimal MCP CallTool models

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
        case type
        case text
        case data
        case mimeType
        case metadata
        case uri
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            let text = try container.decode(String.self, forKey: .text)
            self = .text(text)
        case "image":
            let data = try container.decode(String.self, forKey: .data)
            let mimeType = try container.decode(String.self, forKey: .mimeType)
            let metadata = try container.decodeIfPresent([String: AnyCodable].self, forKey: .metadata)
            self = .image(data: data, mimeType: mimeType, metadata: metadata)
        case "audio":
            let data = try container.decode(String.self, forKey: .data)
            let mimeType = try container.decode(String.self, forKey: .mimeType)
            self = .audio(data: data, mimeType: mimeType)
        case "resource":
            let uri = try container.decode(String.self, forKey: .uri)
            let mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
            let text = try container.decodeIfPresent(String.self, forKey: .text)
            self = .resource(uri: uri, mimeType: mimeType, text: text)
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
    var jsonrpc: String = "2.0"
    let id: Int
    var method: String = "tools/list"
    var params: [String: String] = [:]
}

private struct MCPListToolsResponse: Codable {
    struct Result: Codable {
        struct Tool: Codable {
            let name: String
            let description: String?
            let inputSchema: [String: AnyCodable]?

            enum CodingKeys: String, CodingKey {
                case name
                case description
                case inputSchema
            }
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

// MARK: - Adapter

enum MCPToolAdapter {
    /// Fetch tools from enabled MCP HTTP servers and map them to OpenAI ChatCompletionRequest.Tool
    /// Uses cached tools if available, otherwise returns empty tools
    static func fetchOpenAITools(enabledServerIds: Set<UUID>) async -> ([ChatCompletionRequest.Tool], [String: MCPServer]) {
        let allServers = ChatConfigDefaults().mcpServers
        let servers = allServers.filter { enabledServerIds.contains($0.id) && $0.type == .http && $0.isValid }

        guard !servers.isEmpty else {
            AppLogger.info("MCPToolAdapter: No enabled HTTP servers found")
            return ([], [:])
        }

        AppLogger.info("MCPToolAdapter: Building tools from \(servers.count) servers (using cache)")

        var allTools: [ChatCompletionRequest.Tool] = []
        var toolToServer: [String: MCPServer] = [:]

        for server in servers {
            guard let cachedTools = server.cachedTools, !cachedTools.isEmpty else {
                AppLogger.info("MCPToolAdapter: No cached tools for \(server.name)")
                continue
            }

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
            
            let nameToServer = Dictionary(uniqueKeysWithValues: cachedTools.map { (sanitizeName($0.name), server) })
            allTools.append(contentsOf: openAITools)
            toolToServer.merge(nameToServer) { (current, _) in current }
        }

        // Deduplicate by function name
        var seen = Set<String>()
        let deduped = allTools.filter { tool in
            let name = tool.function.name
            if seen.contains(name) { return false }
            seen.insert(name)
            return true
        }

        let dedupedMap = toolToServer.filter { seen.contains($0.key) }

        AppLogger.info("MCPToolAdapter: Total cached tools: \(deduped.count)")

        return (deduped, dedupedMap)
    }
    
    /// Fetch tools from a specific MCP server for caching
    static func listToolsForServer(server: MCPServer) async throws -> [MCPServerTool] {
        guard server.type == .http && server.isValid else {
            throw NSError(domain: "MCPToolAdapter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid server configuration"])
        }
        
        let tools = try await listToolsHTTP(server: server)
        return tools.map { MCPServerTool(name: $0.name, description: $0.description, inputSchema: $0.inputSchema) }
    }

    // MARK: - Internals

    private static func listToolsHTTP(server: MCPServer) async throws -> [MCPListToolsResponse.Result.Tool] {
        guard let url = URL(string: server.url) else {
            AppLogger.error("MCPToolAdapter: Invalid URL for server \(server.name): \(server.url)")
            return []
        }

        AppLogger.info("MCPToolAdapter: Requesting tools from \(server.name) at \(url)")

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
            AppLogger.error("MCPToolAdapter: Invalid response from \(server.name)")
            return []
        }

        AppLogger.info("MCPToolAdapter: Response status from \(server.name): \(http.statusCode)")

        guard (200...299).contains(http.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unable to read error data"
            AppLogger.error("MCPToolAdapter: HTTP error \(http.statusCode) from \(server.name): \(errorBody)")
            return []
        }

        // Parse SSE response
        let responseString = String(data: data, encoding: .utf8) ?? ""
        let lines = responseString.components(separatedBy: .newlines)
        var jsonData: String?
        for line in lines {
            if line.hasPrefix("data: ") {
                jsonData = String(line.dropFirst(6))
                break
            }
        }
        
        guard let jsonData = jsonData, let jsonBytes = jsonData.data(using: .utf8) else {
            AppLogger.error("MCPToolAdapter: No valid data line in SSE response from \(server.name)")
            return []
        }

        let decoder = JSONDecoder()
        do {
            let listResponse = try decoder.decode(MCPListToolsResponse.self, from: jsonBytes)
            
            if let error = listResponse.error {
                AppLogger.error("MCPToolAdapter: RPC error from \(server.name): \(error.message)")
                // Surface as error to allow caller to ignore per server
                throw error
            }
            
            let tools = listResponse.result?.tools ?? []
            AppLogger.info("MCPToolAdapter: Decoded \(tools.count) tools from \(server.name)")
            
            return tools
        } catch {
            AppLogger.error("MCPToolAdapter: Failed to decode JSON from \(server.name): \(error.localizedDescription)")
            AppLogger.error("MCPToolAdapter: Raw JSON data: \(jsonData)")
            throw error
        }
    }

    /// Call a tool on an MCP HTTP server
    static func callToolHTTP(server: MCPServer, name: String, arguments: [String: AnyCodable]) async throws -> String {
        guard let url = URL(string: server.url) else {
            throw NSError(domain: "MCPToolAdapter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        AppLogger.info("MCPToolAdapter: Calling tool \(name) on \(server.name)")

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
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        request.httpBody = try encoder.encode(body)
        
        if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
            AppLogger.info("MCPToolAdapter: Request body:\n\(bodyString)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "MCPToolAdapter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        AppLogger.info("MCPToolAdapter: Tool call response status: \(http.statusCode)")

        guard (200...299).contains(http.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unable to read error data"
            AppLogger.error("MCPToolAdapter: HTTP error \(http.statusCode): \(errorBody)")
            throw NSError(domain: "MCPToolAdapter", code: 400, userInfo: [NSLocalizedDescriptionKey: errorBody])
        }

        // Parse SSE response
        let responseString = String(data: data, encoding: .utf8) ?? ""
        AppLogger.info("MCPToolAdapter: Raw response:\n\(responseString)")
        
        let lines = responseString.components(separatedBy: .newlines)
        var jsonData: String?
        for line in lines {
            if line.hasPrefix("data: ") {
                jsonData = String(line.dropFirst(6))
                break
            }
        }
        
        guard let jsonData = jsonData, let jsonBytes = jsonData.data(using: .utf8) else {
            AppLogger.error("MCPToolAdapter: No valid data in SSE response")
            throw NSError(domain: "MCPToolAdapter", code: -1, userInfo: [NSLocalizedDescriptionKey: "No valid data in SSE response"])
        }

        AppLogger.info("MCPToolAdapter: Extracted JSON:\n\(jsonData)")

        let decoder = JSONDecoder()
        let callResponse = try decoder.decode(MCPCallToolResponse.self, from: jsonBytes)

        if let error = callResponse.error {
            AppLogger.error("MCPToolAdapter: RPC error: \(error.message)")
            throw NSError(domain: "MCPToolAdapter", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.message])
        }

        // Return the raw JSON result as a string for the AI to process
        if let result = callResponse.result {
            let resultData = try JSONEncoder().encode(result)
            let resultString = String(data: resultData, encoding: .utf8) ?? "{}"
            AppLogger.info("MCPToolAdapter: Tool result JSON:\n\(resultString)")
            return resultString
        }
        
        return "{}"
    }

    private static func sanitizeName(_ name: String) -> String {
        // OpenAI function names: a-z, A-Z, 0-9, underscores, dashes max ~64 chars
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
        let filtered = name.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" }.reduce("") { $0 + String($1) }
        return String(filtered.prefix(64))
    }
}
