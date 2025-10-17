//
//  AddProviderView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/10/2025.
//

import SwiftUI

struct AddProviderView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var registry = ModelRegistry.shared
    @State private var name = ""
    @State private var baseURL = ""
    @State private var apiKey = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Provider Details") {
                    TextField("Name", text: $name)
                    TextField("Base URL", text: $baseURL)
                    SecureField("API Key", text: $apiKey)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Add Provider")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let provider = ModelProvider(
                            name: name,
                            baseURL: baseURL,
                            apiKey: apiKey
                        )
                        registry.addProvider(provider)
                        dismiss()
                    }
                    .disabled(name.isEmpty || baseURL.isEmpty || apiKey.isEmpty)
                }
            }
        }
    }
}
