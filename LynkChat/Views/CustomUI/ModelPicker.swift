//
//  ModelPicker.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ModelPicker: View {
    @Binding var selectedModel: ModelInfo
    var label: String = "Model"
    let enabledModels: [ModelInfo] = ModelRegistry.shared.getEnabledModels()
    
    var body: some View {
        Picker(selection: $selectedModel) {
            ForEach(enabledModels, id: \.id) { modelInfo in
                Label(modelInfo.name, image: modelInfo.theme.imageName)
                    .labelStyle(.titleAndIcon)
                    .tag(modelInfo)
            }
        } label: {
            Label(label, image: selectedModel.imageName)
                .labelStyle(.titleOnly)
        }
        .menuOrder(.fixed)
    }
}
