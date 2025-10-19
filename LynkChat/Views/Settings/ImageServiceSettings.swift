//
//  ImageServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ImageServiceSettings: View {
    @State var config: ImageConfigDefaults = .init()
    
    var body: some View {
        Form {
            Section("Default Models") {
                Picker("Generation Model", selection: $config.defaultModel) {
                    ForEach(ImageModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
                
                Picker("Editing Model", selection: $config.defaultEditingModel) {
                    ForEach(ImageEditingModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
            }
            
            Section("Default Parameters") {
                Stepper(
                    label,
                    value: Binding<Double>(
                        get: { Double(config.numImages) },
                        set: { config.numImages = Int($0) }
                    ),
                    in: 1...4,
                    step: 1,
                    format: .number
                )
            }
            
            Toggle(isOn: $config.saveToPhotos) {
                Text("Save to Photos Library")
                Text("Images will be saved to Downloads folder otherwise")
            }
            
            Section(header: Text("API Keys")) {
                TextField("Wavespeed API Key", text: $config.wavespeedApiKey)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Image Parameters")
        .toolbarTitleDisplayMode(.inline)
    }
    
    var label: String {
        #if os(macOS)
        "Number of Images"
        #else
        "Number of Images (\(config.numImages))"
        #endif
    }
}

#Preview {
    ImageServiceSettings()
}
