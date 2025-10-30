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
    
    init(generations: [Generation], selected: Generation, namespace: Namespace.ID) {
        self.generations = generations
        self.namespace = namespace
        self._selectedIndex = State(initialValue: generations.firstIndex(where: { $0.id == selected.id }) ?? 0)
    }
    
    var body: some View {
        #if os(macOS)
        GalleryImageView(data: generations[selectedIndex].image)
            .zoomable()
            .overlay {
                HStack {
                    Button(action: previous) { Image(systemName: "chevron.left") }
                        .disabled(selectedIndex == 0)
                        .keyboardShortcut(.leftArrow, modifiers: [])
                    Spacer()
                    Button(action: next) { Image(systemName: "chevron.right") }
                        .disabled(selectedIndex >= generations.count - 1)
                        .keyboardShortcut(.rightArrow, modifiers: [])
                }
                .buttonBorderShape(.circle)
                .controlSize(.extraLarge)
                .padding(.horizontal)
            }
        #else
        TabView(selection: $selectedIndex) {
            ForEach(generations.indices, id: \.self) { idx in
                GalleryImageView(data: generations[idx].image)
                    .tag(idx)
                    .zoomable()
            }
        }
        .tabViewStyle(.page)
        .ignoresSafeArea()
        .navigationTransition(.zoom(sourceID: generations[selectedIndex].id, in: namespace))
        #endif
    }
    
    private func next() { if selectedIndex < generations.count - 1 { selectedIndex += 1 } }
    private func previous() { if selectedIndex > 0 { selectedIndex -= 1 } }
}
