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
        self.model = defaults.defaultModel
        self.enabledMCPServerIds = defaults.defaultEnabledMCPServerIds
    }
    
    var temperature: Temperature
    var thinkingBudget: ThinkingBudget
    var systemPrompt: String
    var model: ChatModel
    var enabledMCPServerIds: Set<UUID> = []
    
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
        newConfig.model = self.model
        newConfig.enabledMCPServerIds = self.enabledMCPServerIds
        return newConfig
    }
}
