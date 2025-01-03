//
//  ImageGenOnboarding.swift
//  LynkChat
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct ImageGenOnboarding: View {
    @ObservedObject var imageConfig = ImageModelConfig.shared
    
    var body: some View {
        GenericOnboardingView(
            icon: "photo.stack",
            iconColor: .indigo,
            title: "Generate Beautiful Images",
            content: {
                Form {
                    Section {
                        Picker("Model", selection: $imageConfig.defaultModel) {
                            ForEach(ImageModel.allCases) { model in
                                Text(model.name)
                                    .tag(model)
                            }
                        }
                        
                        Toggle(isOn: $imageConfig.saveToPhotos) {
                            Text("Save to Photos Library")
                            Text("Images will be saved to Downloads folder otherwise")
                        }
                    }
                    #if os(iOS)
                    .listRowBackground(Color(.secondarySystemBackground))
                    #endif
                }
            },
            footerText: "You may configure further in Settings."
        )
    }
}

#Preview {
    ImageGenOnboarding()
}
