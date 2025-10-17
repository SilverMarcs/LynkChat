import Foundation

@Observable
final class ModelRegistry: Sendable {
    static let shared = ModelRegistry()
    let defaults = UserDefaults.standard
    
    private let providersKey = "modelProviders"
    private let modelsKey = "modelInfos"
    
    var providers: [ModelProvider] {
        didSet {
            saveProviders()
        }
    }
    
    var models: [ModelInfo] {
        didSet {
            saveModels()
        }
    }
    
    init() {
        self.providers = []
        self.models = []
        
        self.loadProviders()
        self.loadModels()
    }
    
    func addProvider(_ provider: ModelProvider) {
        providers.append(provider)
    }
    
    func updateProvider(_ provider: ModelProvider) {
        if let index = providers.firstIndex(where: { $0.id == provider.id }) {
            providers[index] = provider
        }
    }
    
    func removeProvider(_ id: UUID) {
        providers.removeAll { $0.id == id }
        models.removeAll { $0.providerId == id }
    }
    
    func addModel(_ model: ModelInfo) {
        models.append(model)
    }
    
    func updateModel(_ model: ModelInfo) {
        if let index = models.firstIndex(where: { $0.id == model.id }) {
            models[index] = model
        }
    }
    
    func removeModel(_ id: UUID) {
        models.removeAll { $0.id == id }
    }
    
    func getProvider(_ id: UUID) -> ModelProvider? {
        providers.first { $0.id == id }
    }
    
    func getModel(_ id: UUID) -> ModelInfo? {
        models.first { $0.id == id }
    }
    
    func getEnabledModels() -> [ModelInfo] {
        models.filter { $0.isEnabled }
    }
    
    func toggleModel(_ id: UUID) {
        if let index = models.firstIndex(where: { $0.id == id }) {
            models[index].isEnabled.toggle()
        }
    }
    
    private func saveProviders() {
        if let encoded = try? JSONEncoder().encode(providers) {
            defaults.set(encoded, forKey: providersKey)
        }
    }
    
    private func loadProviders() {
        if let data = defaults.data(forKey: providersKey),
           let decoded = try? JSONDecoder().decode([ModelProvider].self, from: data) {
            self.providers = decoded
        }
    }
    
    private func saveModels() {
        if let encoded = try? JSONEncoder().encode(models) {
            defaults.set(encoded, forKey: modelsKey)
        }
    }
    
    private func loadModels() {
        if let data = defaults.data(forKey: modelsKey),
           let decoded = try? JSONDecoder().decode([ModelInfo].self, from: data) {
            self.models = decoded
        }
    }
}
