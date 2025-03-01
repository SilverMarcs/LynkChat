//
//  ImageParametersSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI

struct ImageParametersSettings: View {
    @ObservedObject var imageConfig = ImageModelConfig.shared
    var body: some View {
        Form {
            Section {
                Picker("Default Model", selection: $imageConfig.defaultModel) {
                    ForEach(ImageModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
            }
            
            Section(header: Text("Default Parameters")) {
                Stepper(
                    label,
                    value: Binding<Double>(
                        get: { Double(imageConfig.numImages) },
                        set: { imageConfig.numImages = Int($0) }
                    ),
                    in: 1...4,
                    step: 1,
                    format: .number
                )
            }
            
            Toggle(isOn: $imageConfig.saveToPhotos) {
                Text("Save to Photos Library")
                Text("Images will be saved to Downloads folder otherwise")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Image Gen")
        .toolbarTitleDisplayMode(.inline)
    }
    
    var label: String {
        #if os(macOS)
        "Number of Images"
        #else
        "Number of Images (\(imageConfig.numImages))"
        #endif
    }
}

#Preview {
    ImageParametersSettings()
}
