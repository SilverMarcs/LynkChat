//
//  ChatConfigDefaults.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

struct ChatConfigDefaults {
    @AppStorage("defaultModelInfoId") private var defaultModelInfoId: String = ""
    
    var defaultModel: ModelInfo {
        get {
            guard let modelInfoId = UUID(uuidString: defaultModelInfoId) else {
                return getFirstEnabledModel()
            }
            if let modelInfo = ModelRegistry.shared.getModel(modelInfoId) {
                return modelInfo
            }
            return getFirstEnabledModel()
        }
        set {
            defaultModelInfoId = newValue.id.uuidString
        }
    }
    
    private func getFirstEnabledModel() -> ModelInfo {
        guard let first = ModelRegistry.shared.getEnabledModels().first else {
            let models = ModelRegistry.shared.models
            if let model = models.first {
                return model
            }
            return ModelInfo(providerId: UUID(), modelString: "", displayName: "")
        }
        return first
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
    
    @AppStorage("defaultEnabledMCPServerIdsData") private var defaultEnabledMCPServerIdsData: Data = Data()
    var defaultEnabledMCPServerIds: Set<UUID> {
        get {
            (try? JSONDecoder().decode(Set<UUID>.self, from: defaultEnabledMCPServerIdsData)) ?? []
        }
        set {
            defaultEnabledMCPServerIdsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
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
