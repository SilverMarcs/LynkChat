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
    @State private var enabledModels: [ModelInfo] = []
    
    var body: some View {
        Picker(selection: $selectedModel) {
            ForEach(enabledModels, id: \.id) { modelInfo in
                if let provider = ModelRegistry.shared.getProvider(modelInfo.providerId) {
                    let chatModel = ChatModel(providerId: provider.id, modelInfoId: modelInfo.id)
                    Label(modelInfo.displayName, image: modelInfo.theme.imageName)
                        .labelStyle(.titleAndIcon)
                        .tag(chatModel)
                }
            }
        } label: {
            Label(label, image: selectedModel.imageName)
                .labelStyle(.titleOnly)
        }
        .menuOrder(.fixed)
        .onAppear {
            enabledModels = ModelRegistry.shared.getEnabledModels()
        }
    }
}

struct ModelSinglePicker: View {
    @Binding var selectedModel: ChatModel
    @State private var enabledModels: [ModelInfo] = []
    
    var body: some View {
        Menu {
            ForEach(enabledModels, id: \.id) { modelInfo in
                if let provider = ModelRegistry.shared.getProvider(modelInfo.providerId) {
                    let chatModel = ChatModel(providerId: provider.id, modelInfoId: modelInfo.id)
                    Button(action: {
                        selectedModel = chatModel
                    }) {
                        HStack {
                            Label(modelInfo.displayName, image: modelInfo.theme.imageName)
                                .labelStyle(.titleAndIcon)
                            
                            if chatModel == selectedModel {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            Label(selectedModel.name, image: selectedModel.imageName)
                .labelStyle(.titleAndIcon)
        }
        .onAppear {
            enabledModels = ModelRegistry.shared.getEnabledModels()
        }
    }
}

struct ModelMenuPicker: View {
    @Binding var selectedModels: Set<ChatModel>
    @State var showingPopover: Bool = false
    @State private var enabledModels: [ModelInfo] = []
    
    var body: some View {
        HStack {
            Text("Models")
            ForEach(sortedSelectedModels()) { model in
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
                    ForEach(enabledModels, id: \.id) { modelInfo in
                        if let provider = ModelRegistry.shared.getProvider(modelInfo.providerId) {
                            let chatModel = ChatModel(providerId: provider.id, modelInfoId: modelInfo.id)
                            Toggle(isOn: Binding(
                                get: { selectedModels.contains(chatModel) },
                                set: { isOn in
                                    if isOn {
                                        selectedModels.insert(chatModel)
                                    } else {
                                        selectedModels.remove(chatModel)
                                    }
                                }
                            )) {
                                Label(modelInfo.displayName, image: modelInfo.theme.imageName)
                            }
                            .disabled(selectedModels.count == 1 && selectedModels.contains(chatModel))
                        }
                    }
                }
                .padding(8)
            }        
        }
        .onAppear {
            enabledModels = ModelRegistry.shared.getEnabledModels()
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
    
    private func sortedSelectedModels() -> [ChatModel] {
        Array(selectedModels).sorted { $0.name < $1.name }
    }
}

private extension Set where Element == ChatModel {
    func sortedByName() -> [ChatModel] {
        Array(self).sorted { $0.name < $1.name }
    }
}
