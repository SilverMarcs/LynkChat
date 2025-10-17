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
                    .contentShape(.rect)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        registry.removeProvider(provider.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
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
