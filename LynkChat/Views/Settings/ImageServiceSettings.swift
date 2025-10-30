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
            Section {
                Picker("Default Model", selection: $config.defaultModel) {
                    ForEach(ImageModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
                
                Picker("Default Editing Model", selection: $config.defaultEditingModel) {
                    ForEach(ImageEditingModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
            }
            
            
            
            Toggle(isOn: $config.saveToPhotos) {
                Text("Save to Photos Library")
                Text("Images will be saved to Downloads folder otherwise")
            }
            
            Section(header: Text("API Keys")) {
                SecureField("Wavespeed API Key", text: $config.wavespeedApiKey)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Image Parameters")
        .toolbarTitleDisplayMode(.inline)
    }
    
    
}

#Preview {
    ImageServiceSettings()
}
