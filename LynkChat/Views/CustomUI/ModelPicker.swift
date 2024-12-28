//
//  ModelPicker.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ModelPicker: View {
    @Binding var selectedModel: ChatModel
    
    var body: some View {
        Picker("Model", selection: $selectedModel) {
            ForEach(Array(ChatModel.groupedModels().keys), id: \.self) { group in
                Section(header: Text(group.displayName)) {
                    ForEach(ChatModel.groupedModels()[group] ?? []) { model in
                        Text(model.name)
                            .tag(model)
                    }
                }
            }
        }
    }
}
