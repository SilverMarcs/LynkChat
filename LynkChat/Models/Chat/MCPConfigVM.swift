import SwiftUI
import Foundation

@Observable final class MCPConfigVM {
    @ObservationIgnored private let defaults = UserDefaults.standard
    @ObservationIgnored private let mcpServersKey = "mcpServersData"
    @ObservationIgnored private let enabledMCPServerIdsKey = "defaultEnabledMCPServerIdsData"
    
    var mcpServers: [MCPServer] = [] { didSet { persistServers() } }
    var defaultEnabledMCPServerIds: Set<UUID> = [] { didSet { persistEnabledIds() } }
    
    init() {
        loadServers()
        loadEnabledIds()
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
    
    private func loadEnabledIds() {
        guard let data = defaults.data(forKey: enabledMCPServerIdsKey),
              let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) else {
            defaultEnabledMCPServerIds = []
            return
        }
        defaultEnabledMCPServerIds = ids
    }
    
    private func persistEnabledIds() {
        if let encoded = try? JSONEncoder().encode(defaultEnabledMCPServerIds) {
            defaults.set(encoded, forKey: enabledMCPServerIdsKey)
        }
    }
    
    func addServer(_ server: MCPServer) {
        mcpServers.append(server)
    }
    
    func removeServer(withId id: UUID) {
        mcpServers.removeAll { $0.id == id }
        defaultEnabledMCPServerIds.remove(id)
    }
    
    func toggleServerEnabled(_ id: UUID, enabled: Bool) {
        if enabled {
            defaultEnabledMCPServerIds.insert(id)
        } else {
            defaultEnabledMCPServerIds.remove(id)
        }
    }
    
    func isServerEnabled(_ id: UUID) -> Bool {
        defaultEnabledMCPServerIds.contains(id)
    }
}
