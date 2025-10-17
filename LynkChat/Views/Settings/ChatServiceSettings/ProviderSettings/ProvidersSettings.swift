import SwiftUI

struct ProvidersSettings: View {
    @State private var showAddProvider = false
    @State private var registry = ModelRegistry.shared
    
    var body: some View {
        Form {
            ForEach(registry.providers) { provider in
                NavigationLink(destination: ProviderDetailView(provider: provider)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(provider.name)
                                .font(.headline)
                            Text(provider.baseURL)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(registry.models.filter { $0.providerId == provider.id }.count) models")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { offsets in
                offsets.forEach { index in
                    let provider = registry.providers[index]
                    registry.removeProvider(provider.id)
                }
            }
        }
        .formStyle(.grouped)
        .toolbar {
            Button(action: { showAddProvider = true }) {
                Label("Add Provider", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showAddProvider) {
            AddProviderView()
        }
    }
}

#Preview {
    ProvidersSettings()
}
