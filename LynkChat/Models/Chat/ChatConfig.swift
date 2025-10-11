//
//  OldChatConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation
import SwiftData

struct ChatConfig: Identifiable, Codable, Sendable {
    var id = UUID()
    
    init() {
        let defaults = ChatConfigDefaults()
        
        self.temperature = defaults.temperature
        self.thinkingBudget = defaults.thinkingBudget
        self.systemPrompt = defaults.systemPrompt
        self.models = [defaults.defaultModel]
    }
    
    var model: ChatModel {
        get {
            self.models.first!
        }
        set {
            // Remove the old model and add the new one
            self.models.removeAll()
            self.models.insert(newValue)
        }
    }
    
    var temperature: Temperature
    var thinkingBudget: ThinkingBudget
    var systemPrompt: String
    var models: Set<ChatModel> = []
    var enabledMCPServerIds: Set<UUID> = []
    
    // Helper methods for MCP servers
    func isMCPServerEnabled(_ serverId: UUID) -> Bool {
        enabledMCPServerIds.contains(serverId)
    }
    
    mutating func toggleMCPServer(_ serverId: UUID) {
        if isMCPServerEnabled(serverId) {
            enabledMCPServerIds.remove(serverId)
        } else {
            enabledMCPServerIds.insert(serverId)
        }
    }
}

extension ChatConfig {
    func copy() -> ChatConfig {
        var newConfig = ChatConfig()
        newConfig.temperature = self.temperature
        newConfig.thinkingBudget = self.thinkingBudget
        newConfig.systemPrompt = self.systemPrompt
        newConfig.models = self.models
        newConfig.enabledMCPServerIds = self.enabledMCPServerIds
        return newConfig
    }
}
