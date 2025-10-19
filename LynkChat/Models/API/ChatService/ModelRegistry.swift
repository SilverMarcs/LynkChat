import Foundation

@Observable
final class ModelRegistry: Sendable {
    let defaults = UserDefaults.standard
    
    private let modelsKey = "modelInfos"
    
    var models: [ModelInfo] {
        didSet {
            saveModels()
        }
    }
    
    init() {
        self.models = []
        self.loadModels()
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
    
//    func getModel(_ id: UUID) -> ModelInfo? {
//        models.first { $0.id == id }
//    }
    
    func getEnabledModels() -> [ModelInfo] {
        models.filter { $0.isEnabled }
    }
    
    func toggleModel(_ id: UUID) {
        if let index = models.firstIndex(where: { $0.id == id }) {
            models[index].isEnabled.toggle()
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
