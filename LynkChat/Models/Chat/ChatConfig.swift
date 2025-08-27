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
        self.enabledTools = []
    }
    
    var temperature: Temperature
    var thinkingBudget: ThinkingBudget
    var systemPrompt: String
    var model: ChatModel
    var enabledTools: Set<Tool> = []
    var secondaryModels: [ChatModel] = []
    
    // Helper methods to check and modify tool states
    func isToolEnabled(_ tool: Tool) -> Bool {
        enabledTools.contains(tool)
    }
    
    mutating func enableTool(_ tool: Tool) {
        enabledTools.insert(tool)
    }
    
    mutating func disableTool(_ tool: Tool) {
        enabledTools.remove(tool)
    }
    
    mutating func toggleTool(_ tool: Tool) {
        if isToolEnabled(tool) {
            disableTool(tool)
        } else {
            enableTool(tool)
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
        newConfig.enabledTools = self.enabledTools
        newConfig.secondaryModels = self.secondaryModels
        return newConfig
    }
}
