//
//  OldChatConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation
import SwiftData

struct ChatConfig: Identifiable, Codable {
    var id = UUID()
    var temperature: Double = ChatConfigDefaults.shared.temperature
    var maxTokens: MaxTokens = ChatConfigDefaults.shared.maxTokens
    var systemPrompt: String = ChatConfigDefaults.shared.systemPrompt
    var model: ChatModel = ModelConfig.shared.defaultModel
    var enabledTools: Set<Tool> = ChatConfig.defaultEnabledTools()
    
    // Helper method to get default enabled tools from ToolConfigDefaults
    static func defaultEnabledTools() -> Set<Tool> {
        var tools = Set<Tool>()
        let defaults = ToolConfigDefaults.shared
        
        if defaults.webSearch { tools.insert(.webSearch) }
        if defaults.scrapeLinks { tools.insert(.scrapeLinks) }
        if defaults.imageGenerate { tools.insert(.imageGeneration) }
        if defaults.transcribe { tools.insert(.transcribe) }
        
        return tools
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
