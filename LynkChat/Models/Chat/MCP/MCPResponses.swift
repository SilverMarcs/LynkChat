import Foundation

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

struct MCPListToolsResponse: Codable {
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
