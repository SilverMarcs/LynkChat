import Foundation

struct MCPCallToolRequest: Codable {
    var jsonrpc: String = "2.0"
    let id: Int
    var method: String = "tools/call"
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

struct MCPListToolsRequest: Codable {
    var jsonrpc: String = "2.0"
    let id: Int
    var method: String = "tools/list"
    var params: [String: String] = [:]
}
