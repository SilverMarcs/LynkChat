//
//  ModelPicker.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ModelPicker: View {
    @StateObject private var modelConfig = ModelConfig.shared
    @Binding var selectedModel: ChatModel
    
    var enabledModels: [ModelGroup: [ChatModel]] {
        let filtered = ChatModel.allCases.filter { modelConfig.isEnabled($0) }
        return Dictionary(grouping: filtered) { $0.group }
    }
    
    var body: some View {
        Picker("Model", selection: $selectedModel) {
            ForEach(Array(enabledModels.keys), id: \.self) { group in
                if let models = enabledModels[group], !models.isEmpty {
                    Section {
                        ForEach(models) { model in
                            Label(model.name, image: model.imageName)
                                .labelStyle(.titleAndIcon)
                                .tag(model)
                        }
                    }
                }
            }
        }
    }
}
