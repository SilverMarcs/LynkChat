import Foundation

enum MCPHTTPClient {
    static func callToolHTTP(server: MCPServer, name: String, arguments: [String: AnyCodable]) async throws -> String {
        guard let url = URL(string: server.url) else {
            throw RuntimeError("Invalid server URL")
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
            throw RuntimeError("Invalid server response")
        }
        
        guard (200...299).contains(http.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw RuntimeError("HTTP \(http.statusCode): \(errorBody)")
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        guard let jsonData = extractSSEData(from: responseString) else {
            throw RuntimeError("No valid data in response")
        }
        
        let callResponse = try JSONDecoder().decode(MCPCallToolResponse.self, from: jsonData)
        
        if let error = callResponse.error {
            throw RuntimeError("\(error.code): \(error.message)")
        }
        
        if let result = callResponse.result {
            let resultData = try JSONEncoder().encode(result)
            return String(data: resultData, encoding: .utf8) ?? "{}"
        }
        
        return "{}"
    }
    
    static func listToolsHTTP(server: MCPServer) async throws -> [MCPListToolsResponse.Result.Tool] {
        guard let url = URL(string: server.url) else {
            throw RuntimeError("Invalid server URL")
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
            throw RuntimeError("Invalid server response")
        }
        
        guard (200...299).contains(http.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw RuntimeError("HTTP \(http.statusCode): \(errorBody)")
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        guard let jsonData = extractSSEData(from: responseString) else {
            throw RuntimeError("No valid data in response")
        }
        
        let listResponse = try JSONDecoder().decode(MCPListToolsResponse.self, from: jsonData)
        
        if let error = listResponse.error {
            throw RuntimeError("\(error.code): \(error.message)")
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
}
