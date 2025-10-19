//
//  ChatConfigDefaults.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

struct ChatConfigDefaults {
    @AppStorage("defaultModelInfoData") private var defaultModelInfoData: Data = Data()
    var defaultModel: ChatModel {
        get {
            if !defaultModelInfoData.isEmpty,
               let model = try? JSONDecoder().decode(ChatModel.self, from: defaultModelInfoData) {
                return model
            }
            return ChatModel(modelString: "", name: "No Model", baseURL: "", apiKey: "", isEnabled: false)
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                defaultModelInfoData = encoded
            }
        }
    }
    
    @AppStorage("quickPanelDefaultModelInfoData") private var quickPanelDefaultModelInfoData: Data = Data()
    var quickPanelDefaultModel: ChatModel {
        get {
            if !quickPanelDefaultModelInfoData.isEmpty,
               let model = try? JSONDecoder().decode(ChatModel.self, from: quickPanelDefaultModelInfoData) {
                return model
            }
            return ChatModel(modelString: "", name: "No Model", baseURL: "", apiKey: "", isEnabled: false)
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                quickPanelDefaultModelInfoData = encoded
            }
        }
    }
    
    @AppStorage("temperature") var temperature: Temperature = .balanced
    @AppStorage("thinkingBudget") var thinkingBudget: ThinkingBudget = .none
    
    @AppStorage("mcpServersData") private var mcpServersData: Data = Data()
    var mcpServers: [MCPServer] {
        get {
            guard !mcpServersData.isEmpty,
                  let servers = try? JSONDecoder().decode([MCPServer].self, from: mcpServersData) else {
                return []
            }
            return servers
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                mcpServersData = encoded
            }
        }
    }
    
    var enabledMCPServers: [MCPServer] {
        mcpServers.filter { $0.isEnabled }
    }
    
    @AppStorage("quickSystemPrompt") var quickSystemPrompt: String = "Keep your responses fairly concise."
    #if os(macOS)
    @AppStorage("systemPrompt") var systemPrompt: String = String.systemPrompt
    #else
    @AppStorage("systemPrompt") var systemPrompt: String = String.systemPrompt + "\n Be concise with your responses"
    #endif
}

extension String {
    static let systemPrompt = """
    You are a helpful assistant.
    """
}
