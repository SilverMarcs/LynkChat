//
//  ImageServiceSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/12/2024.
//

import SwiftUI

struct ImageServiceSettings: View {
    @AppStorage("saveToPhotos") private var saveToPhotos: Bool = true
    @AppStorage("defaultImageModel") private var defaultModel: ImageModel = .seedreamV50Lite
    @AppStorage("defaultEditingModel") private var defaultEditingModel: ImageEditingModel = .seedreamV50Lite
    @AppStorage("wavespeedApiKey") private var wavespeedApiKey: String = ""

    @Environment(GodMode.self) var godMode

    var body: some View {
        Group {
            if godMode.isActivated {
                Form {
                    Section {
                        Picker("Default Model", selection: $defaultModel) {
                            ForEach(ImageModel.allCases) { model in
                                Label(model.name, image: model.imageName)
                                    .tag(model)
                            }
                        }

                        Picker("Default Editing Model", selection: $defaultEditingModel) {
                            ForEach(ImageEditingModel.allCases) { model in
                                Label(model.name, image: model.imageName)
                                    .tag(model)
                            }
                        }
                    }

                    Toggle(isOn: $saveToPhotos) {
                        Text("Save to Photos Library")
                        Text("Images will be saved to Downloads folder otherwise")
                    }

                    Section(header: Text("API Keys")) {
                        SecureField("Wavespeed API Key", text: $wavespeedApiKey)
                    }
                }
                .formStyle(.grouped)
            } else {
                ContentUnavailableView("Coming Soon", systemImage: "photo.badge.plus", description: Text("Image generation is not available yet."))
            }
        }
        .navigationTitle("Image Parameters")
        .toolbarTitleDisplayMode(.inline)
    }
    
    
}

#Preview {
    ImageServiceSettings()
}
