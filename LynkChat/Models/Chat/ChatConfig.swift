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
    var temperature: Temperature = ChatConfigDefaults.shared.temperature
    var thinkingBudget: ThinkingBudget = ChatConfigDefaults.shared.thinkingBudget
    var maxTokens: MaxTokens = ChatConfigDefaults.shared.maxTokens
    var systemPrompt: String = ChatConfigDefaults.shared.systemPrompt
    var model: ChatModel = ChatConfigDefaults.shared.defaultModel
    var enabledTools: Set<Tool> = []
    
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
        newConfig.maxTokens = self.maxTokens
        newConfig.systemPrompt = self.systemPrompt
        newConfig.model = self.model
        newConfig.enabledTools = self.enabledTools
        return newConfig
    }
}
