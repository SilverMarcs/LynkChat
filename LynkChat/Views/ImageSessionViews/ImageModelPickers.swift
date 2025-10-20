//
//  ImageModelPickers.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/10/2025.
//

import SwiftUI

struct ImageModelPickers: View {
    @Binding var config: ImageConfig
    
    var body: some View {
        Picker("Generation", selection: $config.model) {
            ForEach(ImageModel.allCases) { model in
                Label(model.name, image: model.imageName)
                    .tag(model)
            }
        }

        
        Picker("Editing", selection: $config.editingModel) {
            ForEach(ImageEditingModel.allCases) { model in
                Label(model.name, image: model.imageName)
                    .tag(model)
            }
        }
        
        Picker("Video", selection: $config.videoModel) {
            ForEach(VideoGenerationModel.allCases) { model in
                Label(model.name, image: model.imageName)
                    .tag(model)
            }
        }
    }
}
