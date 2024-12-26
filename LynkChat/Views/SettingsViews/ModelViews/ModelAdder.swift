//
//  ModelAdder.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/10/2024.
//

import SwiftUI

struct ModelAdder: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (String, String) -> Void // Closure that takes model code and name
    
    @State private var modelName: String = ""
    @State private var modelCode: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Model Name", text: $modelName)
                TextField("Model Code", text: $modelCode)
            }
            .formStyle(.grouped)
            .navigationTitle("Add Chat Model")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(modelName, modelCode)
                        dismiss()
                    }
                    .disabled(modelName.isEmpty || modelCode.isEmpty)
                }
            }
        }
    }
}
