//
//  ImageSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI
import SwiftData

struct ImageSettings: View {
    @ObservedObject var imageConfig = ImageConfigDefaults.shared
    
    @State private var selectedTab: ImageTab = .general
    @State private var showProviderAdder = false
    
    @Query var providers: [ImageProvider]
    
    var body: some View {
        Form {
            Toggle(isOn: $imageConfig.saveToPhotos) {
                Text("Save to Photos Library")
                Text("Images will be saved to Downloads folder otherwise")
            }
            
            Section("Models") {
//                Picker("Provider", selection: $providerDefaults.imageProvider) {
//                    ForEach(providers) { provider in
//                        Text(provider.name.uppercased())
//                            .tag(provider)
//                    }
//                }
//                
//                ModelPicker(model: $providerDefaults.imageProvider.model, models: providerDefaults.imageProvider.models, label: "Model")
            }
            
            Section("Default Parameters") {
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
            
            Section("Providers") {
                ImageProviders()
            }
        }
        .sheet(isPresented: $showProviderAdder) {
            ImageProviderAdder()
        }
        .toolbar {
            Button {
                showProviderAdder.toggle()
            } label: {
                Label("Add Provider", systemImage: "plus")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Image Service")
        .toolbarTitleDisplayMode(.inline)
    }
}

enum ImageTab: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case general
    case providers
}

#Preview {
    ImageSettings()
}
