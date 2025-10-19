import SwiftUI

struct ModelSettings: View {
    @State private var showAddModel = false
    @Environment(ModelRegistry.self) var registry
    
    var body: some View {
        Form {
            ForEach(registry.models) { model in
                LabeledContent {
                    Toggle("", isOn: Binding(
                        get: { model.isEnabled },
                        set: { _ in registry.toggleModel(model.id) }
                    ))
                    .toggleStyle(.switch)
                } label: {
                    Text(model.name)
                    Text(model.modelString)
                }
                .contentShape(.rect)
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
    }
}

#Preview {
    ModelSettings()
        .environment(ModelRegistry())
}
