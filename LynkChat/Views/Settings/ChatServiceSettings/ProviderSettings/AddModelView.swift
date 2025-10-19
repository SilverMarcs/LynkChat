//
//  AddModelView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/10/2025.
//

import SwiftUI

struct AddModelView: View {
    @Environment(ModelRegistry.self) var registry
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var modelString = ""
    @State private var baseURL = ""
    @State private var apiKey = ""
    @State private var selectedTheme: ModelTheme = .openai
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Model Details") {
                    TextField("Display Name", text: $name)
                    TextField("Model String", text: $modelString)
                    TextField("Base URL", text: $baseURL)
                    SecureField("API Key", text: $apiKey)
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
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        let model = ChatModel(
                            modelString: modelString,
                            name: name,
                            baseURL: baseURL,
                            apiKey: apiKey,
                            theme: selectedTheme
                        )
                        registry.addModel(model)
                        dismiss()
                    } label: {
                        Label("Add", systemImage: "checkmark")
//                        #if os(macOS)
//                            .labelStyle(.titleOnly)
//                        #endif
                    }
                    .disabled(name.isEmpty || modelString.isEmpty || baseURL.isEmpty || apiKey.isEmpty)
                }
            }
        }
    }
}
