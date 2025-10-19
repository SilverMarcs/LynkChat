import SwiftUI
import Foundation

@Observable
final class MCPConfigVM {
    @ObservationIgnored private let defaults = UserDefaults.standard
    @ObservationIgnored private let mcpServersKey = "mcpServersData"
    
    var mcpServers: [MCPServer] = [] { didSet { persistServers() } }
    
    init() {
        loadServers()
    }
    
    private func loadServers() {
        guard let data = defaults.data(forKey: mcpServersKey),
              !data.isEmpty,
              let servers = try? JSONDecoder().decode([MCPServer].self, from: data) else {
            mcpServers = []
            return
        }
        mcpServers = servers
    }
    
    private func persistServers() {
        if let encoded = try? JSONEncoder().encode(mcpServers) {
            defaults.set(encoded, forKey: mcpServersKey)
        }
    }
    
    func addServer(_ server: MCPServer) {
        mcpServers.append(server)
    }
    
    func removeServer(withId id: UUID) {
        mcpServers.removeAll { $0.id == id }
    }
    
    func toggleServerEnabled(_ id: UUID) {
        if let index = mcpServers.firstIndex(where: { $0.id == id }) {
            mcpServers[index].isEnabled.toggle()
        }
    }
    
    func isServerEnabled(_ id: UUID) -> Bool {
        mcpServers.first(where: { $0.id == id })?.isEnabled ?? false
    }
    
    func enabledServers() -> [MCPServer] {
        mcpServers.filter { $0.isEnabled }
    }
}
