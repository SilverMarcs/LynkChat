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
    
    var modelToEdit: ChatModel?
    
    @State private var name = ""
    @State private var modelString = ""
    @State private var baseURL = ""
    @State private var apiKey = ""
    @State private var selectedTheme: ModelTheme = .openai
    
    private let isEditing: Bool
    private let buttonTitle: String
    private let navTitle: String
    
    init(modelToEdit: ChatModel? = nil) {
        self.modelToEdit = modelToEdit
        self.isEditing = modelToEdit != nil
        self.buttonTitle = modelToEdit != nil ? "Save" : "Add"
        self.navTitle = modelToEdit != nil ? "Edit Model" : "Add Model"
        
        if let model = modelToEdit {
            _name = State(initialValue: model.name)
            _modelString = State(initialValue: model.modelString)
            _baseURL = State(initialValue: model.baseURL)
            _apiKey = State(initialValue: model.apiKey)
            _selectedTheme = State(initialValue: model.theme)
        }
    }
    
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
            .navigationTitle(navTitle)
            .formStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        saveModel()
                    } label: {
                        Label(buttonTitle, systemImage: "checkmark")
                    }
                    .disabled(name.isEmpty || modelString.isEmpty || baseURL.isEmpty || apiKey.isEmpty)
                }
            }
        }
    }
    
    private func saveModel() {
        if isEditing, let original = modelToEdit {
            let updated = ChatModel(
                id: original.id,
                modelString: modelString,
                name: name,
                baseURL: baseURL,
                apiKey: apiKey,
                isEnabled: original.isEnabled,
                theme: selectedTheme
            )
            registry.updateModel(updated)
        } else {
            let model = ChatModel(
                modelString: modelString,
                name: name,
                baseURL: baseURL,
                apiKey: apiKey,
                theme: selectedTheme
            )
            registry.addModel(model)
        }
        dismiss()
    }
}
