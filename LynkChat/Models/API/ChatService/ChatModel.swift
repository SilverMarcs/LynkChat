import Foundation
import UniformTypeIdentifiers

struct ChatModel: Identifiable, Hashable, Codable, Equatable, Sendable, ModelImageProvider {
    var id: String {
        "\(providerId.uuidString):\(modelInfoId.uuidString)"
    }
    
    let providerId: UUID
    let modelInfoId: UUID
    
    init(providerId: UUID, modelInfoId: UUID) {
        self.providerId = providerId
        self.modelInfoId = modelInfoId
    }
    
    var provider: ModelProvider? {
        ModelRegistry.shared.getProvider(providerId)
    }
    
    var modelInfo: ModelInfo? {
        ModelRegistry.shared.getModel(modelInfoId)
    }
    
    var baseURL: String {
        provider?.baseURL ?? ""
    }
    
    var apiKey: String {
        provider?.apiKey ?? ""
    }
    
    var modelString: String {
        modelInfo?.modelString ?? ""
    }
    
    var name: String {
        modelInfo?.displayName ?? "Unknown Model"
    }
    
    var imageName: String {
        modelInfo?.theme.imageName ?? "#00947A"
    }
    
    var color: String {
        modelInfo?.theme.color ?? "#00947A"
    }
    
    var supportedTypes: Set<UTType> {
        [.text, .image]
    }
}
