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
        self.enabledTools = []
    }
    
    var model: ChatModel {
        self.models.first!
    }
    
    var temperature: Temperature
    var thinkingBudget: ThinkingBudget
    var systemPrompt: String
    var models: Set<ChatModel> = []
    var enabledTools: Set<Tool> = []
    
    // Helper methods to check and modify model states
    func isModelEnabled(_ model: ChatModel) -> Bool {
        models.contains(model)
    }
    
    mutating func enableModel(_ model: ChatModel) {
        models.insert(model)
    }
    
    mutating func disableModel(_ model: ChatModel) {
        models.remove(model)
    }
    
    mutating func toggleModel(_ model: ChatModel) {
        if isModelEnabled(model) {
            disableModel(model)
        } else {
            enableModel(model)
        }
    }
    
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
        newConfig.models = self.models
        newConfig.enabledTools = self.enabledTools
        return newConfig
    }
}
