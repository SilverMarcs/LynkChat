//
//  GenerationView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftMediaViewer


struct GenerationView: View {
    var generation: Generation
    private let spacing: CGFloat = 10
    private let size: CGFloat = 300
    
    @State private var isEditingPrompt = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .trailing) {
                ForEach(generation.inputImages, id: \.self) { image in
                    ImageViewerData(data: image, enableSave: false, size: 150)
                        .backgroundExtensionEffect()
                }
                
                Text(generation.config.prompt)
                    .padding(13)
                    .glassEffect(in: .rect(cornerRadius: 24))
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .leading) {
                HStack {
                    AssistantLabel(model: generation.mode == .editing ? generation.config.editingModel : generation.config.model)
                }
                
                if let errorMessage = generation.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                        .padding(.leading, 5)
                        .padding(.top, 1)

                } else {
                    if generation.isGenerating {
//                        LazyVGrid(columns: gridColumns, alignment: .leading, spacing: spacing) {
                            ForEach(1 ... generation.config.numImages, id: \.self) { image in
                                ProgressView()
                                    .frame(width: size, height: size)
                                    .background(.background.secondary, in: .rect(cornerRadius: 15))
                            }
//                        }
                    } else {
                        ForEach(generation.images, id: \.self) { image in
                            ImageViewerData(data: image, size: size)
                                .backgroundExtensionEffect()
                        }
                    }
                
                    if generation.isGenerating {
                        Button(role: .destructive) {
                            generation.stopGenerating()
                        } label: {
                            Text("Stop")
                        }
                        .foregroundStyle(.red)
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .contentShape(.rect)
        .contextMenu {
            Section {
                Button {
//                    editPrompt = generation.config.prompt
                    isEditingPrompt = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button {
                    generation.images = []
                    generation.config.model = generation.session.config.model
                    generation.config.editingModel = generation.session.config.editingModel
                    Task { await generation.send() }
                } label: {
                    Label("Regenerate", systemImage: "arrow.trianglehead.2.clockwise")
                }
            }
            
            Button {
                generation.config.prompt.copyToPasteboard()
            } label: {
                Label("Copy Prompt", systemImage: "document.on.clipboard")
            }
            
            Button(role: .destructive) {
                generation.deleteSelf()
            } label: {
                Label("Delete Generation", systemImage: "trash")
            }
        }
        .sheet(isPresented: $isEditingPrompt) {
            EditGenerationView(generation: generation)
        }
    }
    
    private var gridColumns: [GridItem] {
        #if os(iOS)
        [GridItem(.fixed(size), spacing: spacing)]
        #else
        [GridItem(.fixed(size), spacing: spacing),
        GridItem(.fixed(size), spacing: spacing)]
        #endif
    }
}

