import Foundation
import UniformTypeIdentifiers

struct ModelInfo: Identifiable, Hashable, Codable, Equatable, Sendable, ModelImageProvider {
    var id: UUID = UUID()
    var providerId: UUID
    var modelString: String
    var name: String
    var isEnabled: Bool = true
    var theme: ModelTheme = .openai
    
    init(id: UUID = UUID(), providerId: UUID, modelString: String, name: String, isEnabled: Bool = true, theme: ModelTheme = .openai) {
        self.id = id
        self.providerId = providerId
        self.modelString = modelString
        self.name = name
        self.isEnabled = isEnabled
        self.theme = theme
    }
    
    var provider: ModelProvider {
        ModelRegistry.shared.getProvider(providerId)!
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
