import SwiftUI

struct ModelListSettings: View {
    @State private var showAddModel = false
    @State private var selectedModel: ChatModel?
    @Environment(ModelRegistry.self) var registry
    
    var body: some View {
        Form {
            ForEach(registry.models) { model in
                Button {
                    selectedModel = model
                } label: {
                    HStack {
                        LabeledContent {
                            
                        } label: {
                            Text(model.name)
                            Text(model.modelString)
                        }
                        
                        Spacer()
                        
                        Toggle("Default", isOn: Binding(
                            get: { model.isEnabled },
                            set: { _ in registry.toggleModel(model.id) }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(role: .destructive) {
                        registry.removeModel(model.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Model Settings")
        .toolbar {
            Button(action: { showAddModel = true }) {
                Label("Add Model", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showAddModel) {
            AddModelView()
        }
        .sheet(item: $selectedModel) { model in
            AddModelView(modelToEdit: model)
        }
    }
}

#Preview {
    ModelListSettings()
        .environment(ModelRegistry())
}
