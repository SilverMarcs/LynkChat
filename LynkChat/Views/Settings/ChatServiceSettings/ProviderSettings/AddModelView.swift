//
//  AddModelView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/10/2025.
//

import SwiftUI

struct AddModelView: View {
    let providerId: UUID
    @State private var registry = ModelRegistry.shared
    @State private var displayName = ""
    @State private var modelString = ""
    @State private var selectedTheme: ModelTheme = .openai
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Model Details") {
                    TextField("Display Name", text: $displayName)
                    TextField("Model String", text: $modelString)
                }
                
                Section("Theme") {
                    Picker("Select Theme", selection: $selectedTheme) {
                        ForEach(ModelTheme.allCases, id: \.self) { theme in
                            Label(theme.displayName, image: theme.imageName)
                                .foregroundStyle(Color(hex: theme.color))
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Add Model")
            .formStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        let model = ModelInfo(
                            providerId: providerId,
                            modelString: modelString,
                            displayName: displayName,
                            theme: selectedTheme
                        )
                        registry.addModel(model)
                        dismiss()
                    } label: {
                        Label("Add", systemImage: "checkmark")
                        #if os(macOS)
                            .labelStyle(.titleOnly)
                        #endif
                    }
                    .disabled(displayName.isEmpty || modelString.isEmpty)
                }
            }
        }
    }
}
