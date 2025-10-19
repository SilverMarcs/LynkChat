import Foundation

@Observable
final class ModelRegistry: Sendable {
    let defaults = UserDefaults.standard
    
    private let modelsKey = "modelInfos"
    
    private var _models: [ChatModel] = []
    
    var models: [ChatModel] {
        get {
            _models.sorted { $0.name < $1.name }
        }
        set {
            _models = newValue
            saveModels()
        }
    }
    
    init() {
        self.loadModels()
    }
    
    func addModel(_ model: ChatModel) {
        models.append(model)
    }
    
    func updateModel(_ model: ChatModel) {
        if let index = _models.firstIndex(where: { $0.id == model.id }) {
            _models[index] = model
            saveModels()
        }
    }
    
    func removeModel(_ id: UUID) {
        _models.removeAll { $0.id == id }
        saveModels()
    }
    
    func getEnabledModels() -> [ChatModel] {
        models.filter { $0.isEnabled }
    }
    
    func toggleModel(_ id: UUID) {
        if let index = _models.firstIndex(where: { $0.id == id }) {
            _models[index].isEnabled.toggle()
            saveModels()
        }
    }
    
    private func saveModels() {
        if let encoded = try? JSONEncoder().encode(_models) {
            defaults.set(encoded, forKey: modelsKey)
        }
    }
    
    private func loadModels() {
        if let data = defaults.data(forKey: modelsKey),
           let decoded = try? JSONDecoder().decode([ChatModel].self, from: data) {
            self._models = decoded
        }
    }
}
