//
//  ProviderBackup.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/07/2024.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ProviderBackup: Codable {
    var id: UUID
    var date: Date
    var name: String
    var baseUrl: String
    var apiKey: String
    var type: ProviderType
    var schema: HTTPScheme
    var color: String
    var isEnabled: Bool
    var models: [AIModelBackup]
    var chatModelCode: String
    var liteModelCode: String
    
    struct AIModelBackup: Codable, Hashable, Equatable {
        var id: UUID
        var code: String
        var name: String
        var isEnabled: Bool
    }
}

extension ProviderBackup {
    init(from provider: Provider) {
        self.id = UUID()
        self.date = Date()
        self.name = provider.name
        self.baseUrl = provider.baseUrl
        self.apiKey = provider.apiKey
        self.type = provider.type
        self.schema = provider.scheme
        self.color = provider.color
        self.isEnabled = provider.isEnabled
        self.models = provider.models.map { AIModelBackup(from: $0) }
        self.chatModelCode = provider.chatModel.code
        self.liteModelCode = provider.liteModel.code
    }

    func toProvider() -> Provider {
        let models: [AIModel] = self.models.map { $0.toAIModel() }
        
        return Provider(
            id: UUID(),
            name: self.name,
            baseUrl: self.baseUrl,
            apiKey: self.apiKey,
            type: self.type,
            scheme: self.schema,
            color: self.color,
            isEnabled: self.isEnabled,
            models: models,
            chatModel: models.first(where: { $0.code == self.chatModelCode }) ?? AIModel.gpt4,
            liteModel: models.first(where: { $0.code == self.liteModelCode }) ?? AIModel.gpt4
        )
    }
}

extension ProviderBackup.AIModelBackup {
    init(from model: AIModel) {
        self.id = model.id
        self.code = model.code
        self.name = model.name
        self.isEnabled = model.isEnabled
    }
    
    func toAIModel() -> AIModel {
        AIModel(
            code: self.code,
            name: self.name,
            isEnabled: self.isEnabled
        )
    }
}

struct ProvidersDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var providers: [Provider]

    init(providers: [Provider]) {
        self.providers = providers
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.providers = try JSONDecoder().decode([ProviderBackup].self, from: data).map { $0.toProvider() }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(providers.map { ProviderBackup(from: $0) })
        return FileWrapper(regularFileWithContents: data)
    }
}
