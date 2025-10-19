import Foundation
import SwiftData

struct ChatConfig: Identifiable, Codable, Sendable {
    var id = UUID()
    
    init() {
        let defaults = ChatConfigDefaults()
        
        self.temperature = defaults.temperature
        self.thinkingBudget = defaults.thinkingBudget
        self.systemPrompt = defaults.systemPrompt
        self.model = defaults.defaultModel
        self.enabledMCPServers = defaults.enabledMCPServers
    }
    
    var temperature: Temperature
    var thinkingBudget: ThinkingBudget
    var systemPrompt: String
    var model: ChatModel
    var enabledMCPServers: [MCPServer] = []
    
    func isMCPServerEnabled(_ serverId: UUID) -> Bool {
        enabledMCPServers.contains { $0.id == serverId }
    }
    
    mutating func toggleMCPServer(_ serverId: UUID) {
        if isMCPServerEnabled(serverId) {
            enabledMCPServers.removeAll { $0.id == serverId }
        } else if let server = ChatConfigDefaults().mcpServers.first(where: { $0.id == serverId }) {
            enabledMCPServers.append(server)
        }
    }
}

extension ChatConfig {
    func copy() -> ChatConfig {
        var newConfig = ChatConfig()
        newConfig.temperature = self.temperature
        newConfig.thinkingBudget = self.thinkingBudget
        newConfig.systemPrompt = self.systemPrompt
        newConfig.model = self.model
        newConfig.enabledMCPServers = self.enabledMCPServers
        return newConfig
    }
}
