import Foundation

struct ModelInfo: Identifiable, Codable, Sendable {
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
}
