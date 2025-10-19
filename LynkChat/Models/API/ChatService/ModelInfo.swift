import Foundation
import UniformTypeIdentifiers

struct ModelInfo: Identifiable, Hashable, Codable, Equatable, Sendable, ModelImageProvider {
    var id: UUID
    var modelString: String
    var name: String
    var baseURL: String
    var apiKey: String
    var isEnabled: Bool = true
    var theme: ModelTheme = .openai
    
    init(id: UUID = UUID(), modelString: String, name: String, baseURL: String, apiKey: String, isEnabled: Bool = true, theme: ModelTheme = .openai) {
        self.id = id
        self.modelString = modelString
        self.name = name
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.isEnabled = isEnabled
        self.theme = theme
    }
    
    var imageName: String {
        theme.imageName
    }
    
    var color: String {
        theme.color
    }
    
    var supportedTypes: Set<UTType> {
        [.text, .image, .pdf]
    }
}
