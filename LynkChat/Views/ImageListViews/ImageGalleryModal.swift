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

#if !os(macOS)
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
    #else
    @ViewBuilder
    private var macOSContent: some View {
        GalleryImageView(data: generations[safe: selectedIndex]?.image)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                HStack {
                    Button(action: previous) { Image(systemName: "chevron.left") }
                        .disabled(selectedIndex == 0)
                    Spacer()
                    Button(action: next) { Image(systemName: "chevron.right") }
                        .disabled(selectedIndex >= generations.count - 1)
                }
                .buttonBorderShape(.circle)
                .controlSize(.extraLarge)
                .padding(.horizontal)
            }
    }
    #endif

    private func next() { if selectedIndex < generations.count - 1 { selectedIndex += 1 } }
    private func previous() { if selectedIndex > 0 { selectedIndex -= 1 } }
}

// Safe array subscript
private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
