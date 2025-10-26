//
//  ImageConfigSheet.swift
//  LynkChat
//
//  Created by Codex on 27/10/2025.
//

import SwiftUI

struct ImageConfigSheet: View {
    @Binding var config: ImageConfig
    @Binding var mode: GenerationMode
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Picker("Mode", selection: $mode) {
                ForEach(GenerationMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .controlSize(.large)
            .listRowBackground(Color.clear)
            .listRowInsets(.init())
            
            Section("Models") {
                Picker("Generation", selection: $config.generationModel) {
                    ForEach(ImageModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
                
                
                Picker("Editing", selection: $config.editModel) {
                    ForEach(ImageEditingModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

