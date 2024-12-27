//
//  ModelRefresher.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/10/2024.
//

import SwiftUI

struct ModelRefresher: View {
    @Environment(\.dismiss) var dismiss
    @State private var refreshedModels: [GenericModel] = []
    @State private var isLoading = true
    var provider: Provider

    var body: some View {
        NavigationStack {
            Form {
                if isLoading {
                    ProgressView("Loading models...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task {
                            await loadModels()
                        }
                } else {
                    if refreshedModels.isEmpty {
                        Text("No models found.")
                    } else {
                        List {
                            ForEach(refreshedModels) { model in
                                RefreshModelRow(
                                    model: model,
                                    isSelected: model.isExisting
                                        ? .constant(true)
                                        : binding(for: model)
                                )
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addSelectedModels()
                    }
                    .disabled(refreshedModels.filter { $0.isSelected }.isEmpty)
                }
            }
            #if os(macOS)
            .frame(width: 400, height: 450)
            #else
            .navigationTitle("Refresh Models")
            #endif
        }
    }
    
    private func binding(for model: GenericModel) -> Binding<Bool> {
          Binding(
              get: { refreshedModels[refreshedModels.firstIndex(where: { $0.id == model.id })!].isSelected },
              set: { refreshedModels[refreshedModels.firstIndex(where: { $0.id == model.id })!].isSelected = $0 }
          )
      }

    private func loadModels() async {
        let newModels = await provider.refreshModels()
        
        refreshedModels = newModels.map { model in
            return GenericModel(code: model.code, name: model.name, isExisting: provider.models.contains(where: { $0.code == model.code }))
        }
        
        // Sort to put existing models on top
        refreshedModels.sort { $0.isExisting && !$1.isExisting }
        
        isLoading = false
    }

    private func addSelectedModels() {
        let selectedModels = refreshedModels.filter { $0.isSelected && !$0.isExisting }

        for model in selectedModels {
            provider.models.append(.init(code: model.code, name: model.name))
        }

        dismiss()
    }
}
