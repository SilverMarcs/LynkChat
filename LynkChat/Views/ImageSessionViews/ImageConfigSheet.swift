//
//  ImageConfigSheet.swift
//  LynkChat
//
//  Created by Codex on 27/10/2025.
//

import SwiftUI

struct ImageConfigSheet: View {
    @Bindable var generation: Generation
    
    var body: some View {
        Form {
            Picker("Mode", selection: $generation.generationMode) {
                ForEach(GenerationMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .controlSize(.large)
            .listRowBackground(Color.clear)
            .listRowInsets(.init())
            
            Section("Models") {
                Picker("Generation", selection: $generation.imageConfig.generationModel) {
                    ForEach(ImageModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
                
                
                Picker("Editing", selection: $generation.imageConfig.editModel) {
                    ForEach(ImageEditingModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
            }
            
            #if !os(macOS)
            Section("Prompt") {
                TextField("Enter your thoughts", text: $generation.prompt)
                    .lineLimit(5, reservesSpace: true)
            }
            #endif
        }
        .formStyle(.grouped)
    }
}

