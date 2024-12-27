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
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Title", text: $session.title)
                        .labelsHidden()
                }
                
                Section("Models") {
                    Picker("Model", selection: $session.config.model) {
                        ForEach(ImageModel.allCases) { provider in
                            Text(provider.name.uppercased())
                                .tag(provider)
                        }
                    }
                    
                    // TODO: do thisap
//                    ModelPicker(model: $session.config.model, models: session.config.provider.models, label: "Model")
                }
                
                Section("Parameters") {
                    Picker("N", selection: $session.config.numImages) {
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
            .toolbar {
                Text("Config")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    showingInspector.toggle()
                } label: {
                    #if os(macOS)
                    Label("Toggle Inspector", systemImage: "sidebar.right")
                    #else
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray, .gray.opacity(0.3))
                    #endif
                }
            }
            .formStyle(.grouped)
            #if os(macOS)
            .scrollDisabled(true)
            #endif
        }
    }
    
    private var deleteAllMessages: some View {
        Button(role: .destructive) {
            session.deleteAllGenerations()
        } label: {
            HStack {
                Spacer()
                Text("Delete All Generations")
                Spacer()
            }
        }
        .foregroundStyle(.red)
    }
}

#Preview {
    ImageInspector(session: .mockImageSession, showingInspector: .constant(true))
}
