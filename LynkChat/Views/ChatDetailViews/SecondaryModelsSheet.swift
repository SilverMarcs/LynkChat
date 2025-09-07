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
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(ChatModel.allCases, id: \.self) { model in
                        Toggle(isOn: Binding(
                            get: {
                                if model == config.model {
                                    return true
                                }
                                return config.secondaryModels.contains(model)
                            },
                            set: { isSelected in
                                if model != config.model {
                                    if isSelected {
                                        config.secondaryModels.append(model)
                                    } else {
                                        config.secondaryModels.removeAll { $0 == model }
                                    }
                                }
                            }
                        )) {
                            Label {
                                Text(model.name)
                            } icon: {
                                Image(model.imageName)
                                    .imageScale(.large)
                                    .foregroundStyle(Color(hex: model.color).gradient)
                            }
                        }
                        .disabled(model == config.model)
                    }
                }
            }
            .formStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        dismiss()
                    }
                    .keyboardShortcut(.defaultAction)
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        config.secondaryModels = []
                    }
                }
            }
        }
    }
}

#Preview {
    SecondaryModelsSheet(config: .constant(ChatConfig()))
}
