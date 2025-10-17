import Foundation

struct MCPServerTool: Codable, Hashable, Equatable {
    var id: UUID = UUID()
    let name: String
    let description: String?
    let inputSchema: [String: AnyCodable]?
    
    static func == (lhs: MCPServerTool, rhs: MCPServerTool) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
