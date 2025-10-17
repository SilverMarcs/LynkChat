//
//  ProviderDetailView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/10/2025.
//

import SwiftUI

struct ProviderDetailView: View {
    let provider: ModelProvider
    @State private var registry = ModelRegistry.shared
    @State private var editingProvider: ModelProvider
    @State private var showingAddModelSheet = false
    
    init(provider: ModelProvider) {
        self.provider = provider
        _editingProvider = State(initialValue: provider)
    }
    
    var body: some View {
        Form {
            Section("Provider Details") {
                TextField("Name", text: $editingProvider.name)
                TextField("Base URL", text: $editingProvider.baseURL)
                SecureField("API Key", text: $editingProvider.apiKey)
            }
            
            Section {
                ForEach(registry.models.filter { $0.providerId == provider.id }) { model in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(model.displayName)
                                .font(.headline)
                            Text(model.modelString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { model.isEnabled },
                            set: { _ in registry.toggleModel(model.id) }
                        ))
                    }
                }
                .onDelete { offsets in
                    offsets.forEach { index in
                        let providersModels = registry.models.filter { $0.providerId == provider.id }
                        let model = providersModels[index]
                        registry.removeModel(model.id)
                    }
                }
            } header: {
                Text("Models")
            } footer: {
                Button {
                    showingAddModelSheet = true
                } label: {
                    Label("Add Model", systemImage: "plus")
                }
            }
        }
        .navigationTitle(provider.name)
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    registry.updateProvider(editingProvider)
                } label: {
                    Label("Save Changes", systemImage: "checkmark")
                }
            }
        }
        .sheet(isPresented: $showingAddModelSheet) {
            AddModelView(providerId: provider.id)
        }
    }
}
