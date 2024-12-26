//
//  Provider.swift
//  LynkChat
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData

@Model
class Provider: ProviderImageProvider {
    var id: UUID = UUID()
    
    var name: String = ""
    var baseUrl: String = ""
    @Attribute(.allowsCloudEncryption)
    var apiKey: String = ""
    
    var color: String = "#00947A"
    var isEnabled: Bool = true
    
    var type: ProviderType
    var scheme: HTTPScheme
    
    @Relationship(deleteRule: .cascade)
    var models: [AIModel]
    
    @Relationship(deleteRule: .nullify)
    var chatModel: AIModel
    @Relationship(deleteRule: .nullify)
    var liteModel: AIModel

    public init(id: UUID = UUID(),
                name: String,
                baseUrl: String,
                apiKey: String,
                type: ProviderType,
                scheme: HTTPScheme,
                color: String,
                isEnabled: Bool,
                models: [AIModel] = [],
                chatModel: AIModel,
                liteModel: AIModel) {
        self.id = id
        self.name = name
        self.baseUrl = baseUrl
        self.apiKey = apiKey
        self.type = type
        self.scheme = scheme
        self.color = color
        self.isEnabled = isEnabled
        self.models = models
        self.chatModel = chatModel
        self.liteModel = liteModel
    }
    
    static func factory(type: ProviderType) -> Provider {
        let allModels = type.getDefaultModels()
        
        let chatModel = allModels.first
        
        let provider = Provider(
            name: type.name,
            baseUrl: type.defaultHost,
            apiKey: "",
            type: type,
            scheme: type.scheme,
            color: type.defaultColor,
            isEnabled: true,
            models: allModels,
            chatModel: chatModel!,
            liteModel: chatModel!
        )
        
        return provider
    }
    
    func toApiProvidr() -> APIProvider {
        return .init(name: type.rawValue, baseUrl: baseUrl, apiKey: apiKey)
    }
    
    var imageName: String {
        self.type.imageName
    }
}

extension Provider {
    func refreshModels() async -> [GenericModel] {
        let service = type.getService()
        let refreshedChatModels: [GenericModel] = await service.refreshModels(provider: self.type.rawValue)
        
        return refreshedChatModels.map { chatModel in
            GenericModel(code: chatModel.code, name: chatModel.name)
        }
    }
    
    func testModel(model: AIModel) async -> Bool {
        let service = type.getService()
        
        let testMessage = APIMessage(
            role: .user,
            text: String.testPrompt
        )
        
        let request = APIRequest(
            provider: self.toApiProvidr(),
            model: model.code,
            messages: [testMessage],
            system: nil,
            stream: false
        )
        
        do {
            let response = try await service.nonStreamingResponse(from: request)
            return !response.text.isEmpty
        } catch {
            print("Test chat model failed: \(error)")
            return false
        }
    }
}
