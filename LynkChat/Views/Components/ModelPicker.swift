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
        Picker(selection: $selectedModel) {
            ForEach(ChatModel.allCases, id: \.self) { model in
                Label(model.name, image: model.imageName)
                    .labelStyle(.titleAndIcon)
                    .tag(model)
            }
        } label: {
            Label(label, image: selectedModel.imageName)
                .labelStyle(.titleAndIcon)
        }
        .menuOrder(.fixed)
    }
}

struct ModelSinglePicker: View {
    @Binding var selectedModel: ChatModel
    
    var body: some View {
        Menu {
            ForEach(ChatModel.allCases, id: \.self) { model in
                Button(action: {
                    selectedModel = model
                }) {
                    HStack {
                        Label(model.name, image: model.imageName)
                            .labelStyle(.titleAndIcon)
                        
                        if model == selectedModel {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label(selectedModel.name, image: selectedModel.imageName)
                .labelStyle(.titleAndIcon)
        }
    }
}



struct ModelMenuPicker: View {
    @Binding var selectedModels: Set<ChatModel>
    @State var showingPopover: Bool = false
    
    var body: some View {
        HStack {
            Text("Models")
            ForEach(selectedModels.sortedByName()) { model in
                Label(labelText, image: model.imageName)
                    .foregroundStyle(Color(hex: model.color))
                    .labelStyle(.iconOnly)
            }
            
            Spacer()
            
            Button {
                showingPopover.toggle()
            } label: {
                Text("Select models")
            }
            .popover(isPresented: $showingPopover) {
                VStack(alignment: .leading) {
                    ForEach(ChatModel.allCases, id: \.self) { model in
                        Toggle(isOn: Binding(
                            get: { selectedModels.contains(model) },
                            set: { isOn in
                                if isOn {
                                    selectedModels.insert(model)
                                } else {
                                    selectedModels.remove(model)
                                }
                            }
                        )) {
                            Label(model.name, image: model.imageName)
                        }
                        .disabled(selectedModels.count == 1 && selectedModels.contains(model))
                    }
                }
                .padding(8)
            }        
        }
    }
    
    private var labelText: String {
        switch selectedModels.count {
        case 0:
            return "No Models"
        case 1:
            return selectedModels.first?.name ?? "1 Model"
        default:
            return "\(selectedModels.count) Models"
        }
    }
}

private extension Set where Element == ChatModel {
    func sortedByName() -> [ChatModel] {
        Array(self).sorted { $0.name < $1.name }
    }
}
