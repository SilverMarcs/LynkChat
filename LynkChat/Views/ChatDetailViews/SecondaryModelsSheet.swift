//
//  SecondaryModelsSheet.swift
//  LynkChat
//
//  Created by GitHub Copilot on 28/08/2025.
//

import SwiftUI

struct SecondaryModelsSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var config: ChatConfig
    
    var availableModels: [ChatModel] {
        ChatModel.allCases.filter { $0 != config.model }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(availableModels, id: \.self) { model in
                        Toggle(isOn: Binding(
                            get: { config.secondaryModels.contains(model) },
                            set: { isSelected in
                                if isSelected {
                                    config.secondaryModels.append(model)
                                } else {
                                    config.secondaryModels.removeAll { $0 == model }
                                }
                            }
                        )) {
                            HStack {
                                Image(model.imageName)
                                    .imageScale(.large)
                                    .foregroundStyle(Color(hex: model.color).gradient)
                                
                                Text(model.name)
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .overlay(alignment: .topTrailing) {
                Button(role: .close) {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .controlSize(.large)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .padding(10)
            }
        }
    }
}

#Preview {
    SecondaryModelsSheet(config: .constant(ChatConfig()))
}
