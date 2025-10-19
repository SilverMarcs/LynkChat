import Foundation

enum MCPHTTPClient {
    static func callToolHTTP(server: MCPServer, name: String, arguments: [String: AnyCodable]) async throws -> String {
        let url = URL(string: server.url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = MCPCallToolRequest(id: Int.random(in: 1...1_000_000), name: name, arguments: arguments)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let responseString = String(data: data, encoding: .utf8) ?? ""
        let jsonData = extractSSEData(from: responseString)!
        
        let callResponse = try JSONDecoder().decode(MCPCallToolResponse.self, from: jsonData)
        
        if let result = callResponse.result {
            return String(data: try JSONEncoder().encode(result), encoding: .utf8) ?? "{}"
        }
        
        return "{}"
    }
    
    static func listToolsHTTP(server: MCPServer) async throws -> [MCPListToolsResponse.Result.Tool] {
        let url = URL(string: server.url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = MCPListToolsRequest(id: Int.random(in: 1...1_000_000))
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let responseString = String(data: data, encoding: .utf8) ?? ""
        let jsonData = extractSSEData(from: responseString)!
        
        let listResponse = try JSONDecoder().decode(MCPListToolsResponse.self, from: jsonData)
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
}
