//
//  ChatConfigDefaults.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

struct ChatConfigDefaults {
    @AppStorage("defaultModelProviderId") private var defaultModelProviderId: String = ""
    @AppStorage("defaultModelInfoId") private var defaultModelInfoId: String = ""
    
    var defaultModel: ChatModel {
        get {
            guard let providerId = UUID(uuidString: defaultModelProviderId),
                  let modelInfoId = UUID(uuidString: defaultModelInfoId) else {
                return getFirstEnabledModel()
            }
            return ChatModel(providerId: providerId, modelInfoId: modelInfoId)
        }
        set {
            defaultModelProviderId = newValue.providerId.uuidString
            defaultModelInfoId = newValue.modelInfoId.uuidString
        }
    }
    
    private func getFirstEnabledModel() -> ChatModel {
        guard let first = ModelRegistry.shared.getEnabledModels().first else {
            let providers = ModelRegistry.shared.providers
            let models = ModelRegistry.shared.models
            if let provider = providers.first, let model = models.first {
                return ChatModel(providerId: provider.id, modelInfoId: model.id)
            }
            return ChatModel(providerId: UUID(), modelInfoId: UUID())
        }
        if let provider = ModelRegistry.shared.getProvider(first.providerId) {
            return ChatModel(providerId: provider.id, modelInfoId: first.id)
        }
        return ChatModel(providerId: UUID(), modelInfoId: UUID())
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
