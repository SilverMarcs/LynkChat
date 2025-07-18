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
            Label("Model", image: selectedModel.imageName)
                .labelStyle(.titleAndIcon)
        }
        .menuOrder(.fixed)
    }
}


struct ModelPopoverPicker: View {
    @Binding var selectedModel: ChatModel
    @State private var showPopover = false
    
    var body: some View {
        Button(action: {
            showPopover = true
        }) {
            HStack {
                Label(selectedModel.name, image: selectedModel.imageName)
                    .labelStyle(.titleAndIcon)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
        }
        .popover(isPresented: $showPopover) {
            Form {
                ForEach(ChatModel.allCases, id: \.self) { model in
                    Button(action: {
                        selectedModel = model
                        showPopover = false
                    }) {
                        HStack {
                            Label(model.name, image: model.imageName)
                                .labelStyle(.titleAndIcon)
                            
                            Spacer()
                            
                            if model == selectedModel {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
            .formStyle(.grouped)
        }
    }
}

struct ModelMenuPicker: View {
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
