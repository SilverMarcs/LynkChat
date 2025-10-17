import Foundation

struct ModelProvider: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var name: String
    var baseURL: String
    var apiKey: String
    
    init(id: UUID = UUID(), name: String, baseURL: String, apiKey: String) {
        self.id = id
        self.name = name
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
}
