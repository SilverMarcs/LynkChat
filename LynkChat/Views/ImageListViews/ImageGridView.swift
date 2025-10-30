//
//  ImageGridView.swift
//  LynkChat
//
//  Created by Codex on 30/10/2025.
//

import SwiftUI

struct ImageGridView: View {
    let generations: [Generation]

    @State private var selectedIndex: Int? = nil
    @State private var showGallery: Bool = false
    @Namespace private var imageNamespace

    private let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(generations.enumerated()), id: \.element) { item in
                    Button {
                        if !item.element.isProcessing {
                            selectedIndex = item.offset
                            showGallery = true
                        }
                    } label: {
                        GenerationThumbnailView(generation: item.element)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: item.element.id, in: imageNamespace)
                    .contextMenu {
                        Section {
                            Button {
                                item.element.config.prompt.copyToPasteboard()
                            } label: {
                                Label("Copy Prompt", systemImage: "document.on.clipboard")
                            }
                            
                            Button(role: .destructive) {
                                item.element.deleteSelf()
                            } label: {
                                Label("Delete Generation", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding()
        }
        #if os(macOS)
        .sheet(isPresented: $showGallery) {
            ImageGalleryModal(
                generations: generations,
                initialIndex: selectedIndex ?? 0,
                namespace: imageNamespace
            )
            .frame(minWidth: 700, minHeight: 500)
        }
        #else
        .fullScreenCover(isPresented: $showGallery) {
            ImageGalleryModal(
                generations: generations,
                initialIndex: selectedIndex ?? 0,
                namespace: imageNamespace
            )
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
                    }
                }
        }
    }
}
