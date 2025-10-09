//
//  ImageInspector.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageInspector: View {
    @Bindable var session: ImageSession
    
    @Binding var showingInspector: Bool
    
    var body: some View {
        Form {
            Section("Title") {
                TextField("Title", text: $session.title)
                    .labelsHidden()
            }
            
            Section("Configuration") {
                Picker("Model", selection: $session.config.model) {
                    ForEach(ImageModel.allCases) { model in
                        Label(model.name, image: model.imageName)
                            .tag(model)
                    }
                }
                .labelStyle(.titleAndIcon)
                
                Picker("Mode", selection: $session.config.mode) {
                    ForEach(ImageMode.allCases, id: \.self) { mode in
                        Text(mode.displayName)
                            .tag(mode)
                    }
                }
            }
            
            Section("Parameters") {
                Picker("Number of Images", selection: $session.config.numImages) {
                    ForEach(1 ... 4, id: \.self) { num in
                        Text(String(num)).tag(num)
                    }
                }
                
//                    Picker("Size", selection: $session.config.size) {
//                        ForEach(ImagesQuery.Size.allCases, id: \.self) { size in
//                            Text(size.rawValue.capitalized).tag(size)
//                        }
//                    }
//
//                    Picker("Quality", selection: $session.config.quality) {
//                        ForEach(ImagesQuery.Quality.allCases, id: \.self) { quality in
//                            Text(quality.rawValue.uppercased()).tag(quality)
//                        }
//                    }
//
//                    Picker("Style", selection: $session.config.style) {
//                        ForEach(ImagesQuery.Style.allCases, id: \.self) { style in
//                            Text(style.rawValue.capitalized).tag(style)
//                        }
//                    }
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem {
                Spacer()
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingInspector.toggle()
                } label: {
                    Label("Toggle Inspector", systemImage: "sidebar.right")
                }
            }
        }

    }
}

#Preview {
    ImageInspector(session: .mockImageSession, showingInspector: .constant(true))
}
