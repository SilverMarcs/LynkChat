//
//  ImageGridView.swift
//  LynkChat
//
//  Created by Codex on 30/10/2025.
//

import SwiftUI

struct ImageGridView: View {
    let generations: [Generation]
    
    @State private var selectedGeneration: Generation?
    @Namespace private var imageNamespace
    
    private let columns = [GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(generations.reversed()) { generation in
                    Button {
                        if !generation.isProcessing, generation.image != nil {
                            selectedGeneration = generation
                        }
                    } label: {
                        GenerationThumbnailView(generation: generation)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: generation.id, in: imageNamespace)
                    .contextMenu {
                        Section {
                            if let image = generation.image {
                                Button {
                                    generation.session.inputImages = [image]
                                } label: {
                                    Label("Set as Source", systemImage: "photo.badge.plus")
                                }
                            }
                            
                            Button {
                                generation.config.prompt.copyToPasteboard()
                            } label: {
                                Label("Copy Prompt", systemImage: "document.on.clipboard")
                            }
                        }
                        
                        Button(role: .destructive) {
                            generation.deleteSelf()
                        } label: {
                            Label("Delete Generation", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        #if os(macOS)
        .sheet(item: $selectedGeneration) { generation in
            ImageGalleryModal(generations: generations.reversed(), selected: generation, namespace: imageNamespace)
        }
        #else
        .fullScreenCover(item: $selectedGeneration) { generation in
            ImageGalleryModal(generations: generations.reversed(), selected: generation, namespace: imageNamespace)
                .ignoresSafeArea()
        }
        #endif
    }
}

private struct GenerationThumbnailView: View {
    let generation: Generation

    var body: some View {
        if let data = generation.image, let platformImage = PlatformImage.from(data: data) {
            Image(platformImage: platformImage)
                .resizable()
                 .scaledToFit()
        } else {
            Rectangle()
                .fill(.background.secondary)
                .aspectRatio(9/16, contentMode: .fit)
                .overlay {
                    if generation.isProcessing {
                        ProgressView()
                    } else if generation.isFailed {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                    }
                }
        }
    }
}
