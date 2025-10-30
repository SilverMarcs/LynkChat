//
//  ImageGalleryModal.swift
//  LynkChat
//
//  Created by Codex on 30/10/2025.
//

import SwiftUI

struct ImageGalleryModal: View {
    let generations: [Generation]
    let namespace: Namespace.ID
    @State private var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss

    init(generations: [Generation], initialIndex: Int, namespace: Namespace.ID) {
        self.generations = generations
        self._selectedIndex = State(initialValue: initialIndex)
        self.namespace = namespace
    }

    var body: some View {
        #if os(macOS)
        macOSContent
        #else
        iOSContent
        #endif
    }

    @ViewBuilder
    private var iOSContent: some View {
        TabView(selection: $selectedIndex) {
            ForEach(generations.indices, id: \.self) { idx in
                GalleryImageView(data: generations[idx].image)
                    .tag(idx)
                    .zoomable()
            }
        }
        .tabViewStyle(.page)
        .ignoresSafeArea()
        .navigationTransition(.zoom(sourceID: generations[safe: selectedIndex]?.id ?? UUID(), in: namespace))
    }

    @ViewBuilder
    private var macOSContent: some View {
        GalleryImageView(data: generations[safe: selectedIndex]?.image)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding()

                    Spacer()

                    HStack {
                        Button(action: previous) { Image(systemName: "chevron.left") }
                            .disabled(selectedIndex == 0)
                        Spacer()
                        Button(action: next) { Image(systemName: "chevron.right") }
                            .disabled(selectedIndex >= generations.count - 1)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        .frame(minWidth: 600, minHeight: 400)
    }

    private func next() { if selectedIndex < generations.count - 1 { selectedIndex += 1 } }
    private func previous() { if selectedIndex > 0 { selectedIndex -= 1 } }
}

private struct GalleryImageView: View {
    let data: Data?
    @State private var showCheckmark = false
    
    var body: some View {
        if let data, let platformImage = UIImage(data: data) {
            Image(platformImage: platformImage)
                .resizable()
                 .scaledToFit()
                 .overlay(alignment: .topTrailing) {
                     Button(action: saveImage) {
                         Image(systemName: showCheckmark ? "checkmark" : "square.and.arrow.down")
                     }
                     .buttonStyle(.glass)
                     .controlSize(.large)
                     .buttonBorderShape(.circle)
                     .padding(10)
                 }
        }
    }
    
    func saveImage() {
        if let data = data {
            ImageSaveUtil.saveImage(data: data) { success in
                if success {
                    DispatchQueue.main.async {
                        showCheckmark = true
                        
                        // Revert back to the original icon after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCheckmark = false
                        }
                    }
                }
            }
        }
    }
}

// Safe array subscript
private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
