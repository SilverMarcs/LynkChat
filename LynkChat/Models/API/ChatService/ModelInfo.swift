import Foundation
import UniformTypeIdentifiers

struct ModelInfo: Identifiable, Hashable, Codable, Equatable, Sendable, ModelImageProvider {
    var id: UUID = UUID()
    var providerId: UUID
    var modelString: String
    var displayName: String
    var isEnabled: Bool = true
    var theme: ModelTheme = .openai
    
    init(id: UUID = UUID(), providerId: UUID, modelString: String, displayName: String, isEnabled: Bool = true, theme: ModelTheme = .openai) {
        self.id = id
        self.providerId = providerId
        self.modelString = modelString
        self.displayName = displayName
        self.isEnabled = isEnabled
        self.theme = theme
    }
    
    var provider: ModelProvider {
        ModelRegistry.shared.getProvider(providerId)!
    }
    
    var name: String {
        displayName
    }
    
    var imageName: String {
        theme.imageName
    }
    
    var color: String {
        theme.color
    }
    
    var supportedTypes: Set<UTType> {
        [.text, .image]
    }
}
