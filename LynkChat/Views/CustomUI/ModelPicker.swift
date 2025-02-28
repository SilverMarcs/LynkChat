//
//  ModelPicker.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ModelPicker: View {
    @Binding var selectedModel: ChatModel
    var label: String = "Model"
    
    var body: some View {
        Picker(label, selection: $selectedModel) {
            ForEach(ChatModel.allCases, id: \.self) { model in
                Label(model.name, image: model.imageName)
                    .labelStyle(.titleAndIcon)
                    .tag(model)
            }
        }
        .menuOrder(.fixed)
    }
}
