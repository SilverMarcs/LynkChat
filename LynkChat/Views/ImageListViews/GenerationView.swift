//
//  GenerationView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI

struct GenerationView: View {
    var generation: Generation
    private let spacing: CGFloat = 10
    private let size: CGFloat = 300
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .trailing) {
//                LazyVGrid(columns: gridColumns, alignment: .leading, spacing: spacing) {
                FlowLayout {
                    ForEach(generation.inputImages, id: \.self) { image in
                        ImageViewerData(data: image, size: 200)
                            .backgroundExtensionEffect()
                    }
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
                    
                    if generation.mode == .editing {
                        Text("Edit")
                            .font(.caption.bold())
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.accentColor.opacity(0.12))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(.capsule)
                    }
                }
                
                if generation.state == .error {
                    Text(generation.errorMessage)
                        .foregroundStyle(.white)
                        .textSelection(.enabled)
                        .foregroundStyle(.red)
                        .padding(.leading, 5)
                        .padding(.top, 1)

                } else {
                    LazyVGrid(columns: gridColumns, alignment: .leading, spacing: spacing) {
                        if generation.state == .generating {
                            ForEach(1 ... generation.config.numImages, id: \.self) { image in
                                ProgressView()
                                    .frame(width: size, height: size)
                                    .background(.background.secondary, in: .rect(cornerRadius: 15))
                            }
                        } else if generation.state == .success {
                            ForEach(generation.images, id: \.self) { image in
                                ImageViewerData(data: image)
                                    .backgroundExtensionEffect()
                            }
                        }
                    }
                    
                    if generation.state == .generating {
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
                    generation.images = []
                    generation.config.model = generation.session?.config.model ?? .seedream
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


#Preview {
    GenerationView(generation: .mockGeneration)
}
