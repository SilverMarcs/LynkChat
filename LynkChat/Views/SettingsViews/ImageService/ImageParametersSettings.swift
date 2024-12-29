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
            Toggle(isOn: $imageConfig.saveToPhotos) {
                Text("Save to Photos Library")
                Text("Images will be saved to Downloads folder otherwise")
            }
            
            Section("Models") {
                Picker("Default", selection: $imageConfig.defaultModel) {
                    ForEach(ImageModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
            }
            
            Section(header: Text("Default Parameters")) {
                Stepper(
                    "Number of Images (\(imageConfig.numImages))",
                    value: Binding<Double>(
                        get: { Double(imageConfig.numImages) },
                        set: { imageConfig.numImages = Int($0) }
                    ),
                    in: 1...4,
                    step: 1,
                    format: .number
                )
                
//                
//                Picker("Size", selection: $imageConfig.size) {
//                    ForEach(ImagesQuery.Size.allCases, id: \.self) { size in
//                        Text(size.rawValue)
//                    }
//                }
//                
//                Picker("Quality", selection: $imageConfig.quality) {
//                    ForEach(ImagesQuery.Quality.allCases, id: \.self) { quality in
//                        Text(quality.rawValue.uppercased())
//                    }
//                }
//                
//                Picker("Style", selection: $imageConfig.style) {
//                    ForEach(ImagesQuery.Style.allCases, id: \.self) { style in
//                        Text(style.rawValue.capitalized)
//                    }
//                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Image Gen")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    ImageParametersSettings()
}
