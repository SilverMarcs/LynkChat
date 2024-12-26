//
//  ImageProviderAdder.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI

struct ImageProviderAdder: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var name = ""
    @State var baseUrl = ""
    @State var apiKey = ""

    @State var modelName = ""
    @State var modelCode = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Provider Name", text: $name)
                }
                
                Section {
                    TextField(text: $baseUrl) {
                        Text("Base URL")
                        Text("Exclude https:// but include /v1 if necessary")
                    }
                    TextField("API Key", text: $apiKey)
                }
                
                Section("Add at least one Model") {
                    TextField("Model Name", text: $modelName)
                    TextField("Model Code", text: $modelCode)
                }
            }
            .formStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let imageProvider = ImageProvider(name: name, baseUrl: baseUrl, model: .init(code: modelCode, name: modelName))
                        modelContext.insert(imageProvider)
                        dismiss()
                    }
                    .disabled(name.isEmpty || baseUrl.isEmpty || apiKey.isEmpty || modelName.isEmpty || modelCode.isEmpty)
                }
            }
        }
    }
}
