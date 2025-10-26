//
//  ImageTaskModal.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/10/2025.
//

import SwiftUI

struct ImageTaskModal: View {
    let tasks: [ImageTask]
    let selectedID: UUID
    let namespace: Namespace.ID
    
    @State private var selectionID: UUID
    
    init(tasks: [ImageTask], selectedID: UUID, namespace: Namespace.ID) {
        self.tasks = tasks
        self.selectedID = selectedID
        self.namespace = namespace
        self._selectionID = State(initialValue: selectedID)
    }
    
    private var currentTask: ImageTask? {
        tasks.first(where: { $0.id == selectionID })
    }
    
    private var currentIndex: Int {
        tasks.firstIndex(where: { $0.id == selectionID }) ?? 0
    }
    
    public var body: some View {
#if os(macOS)
        macOSContent
#else
        iOSContent
#endif
    }
    
    @ViewBuilder
    private var iOSContent: some View {
        TabView(selection: $selectionID) {
            ForEach(tasks) { task in
                if let imageData = task.imageData,
                   let platformImage = PlatformImage.from(data: imageData) {
                    Image(platformImage: platformImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .zoomable()
                        .tag(task.id)
                        .overlay(alignment: .topTrailing) {
                            SaveImageButton(data: task.imageData)
                                .padding()
                        }
                        #if !os(macOS)
                        .matchedTransitionSource(id: task.id, in: namespace)
                        #endif
                }
            }
        }
        .ignoresSafeArea()
        .tabViewStyle(.page)
        #if !os(macOS)
        .navigationTransition(.zoom(sourceID: selectionID, in: namespace))
        #endif
    }
    
    @ViewBuilder
    private var macOSContent: some View {
        if let task = currentTask,
           let imageData = task.imageData,
           let platformImage = PlatformImage.from(data: imageData) {
            Image(platformImage: platformImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .zoomable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .top) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.prompt)
                                .font(.callout)
                            Text("\(currentIndex + 1) of \(tasks.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
                .overlay {
                    if tasks.count > 1 {
                        HStack {
                            Button(action: previousImage) {
                                Image(systemName: "chevron.left")
                            }
                            .controlSize(.extraLarge)
                            .buttonStyle(.glass)
                            .buttonBorderShape(.circle)
                            .disabled(currentIndex == 0)
                            
                            Spacer()
                            
                            Button(action: nextImage) {
                                Image(systemName: "chevron.right")
                            }
                            .controlSize(.extraLarge)
                            .buttonStyle(.glass)
                            .buttonBorderShape(.circle)
                            .disabled(currentIndex == tasks.count - 1)
                        }
                        .padding(.horizontal)
                    }
                }
        }
    }
    
    private func nextImage() {
        guard let idx = tasks.firstIndex(where: { $0.id == selectionID }), idx < tasks.count - 1 else { return }
        selectionID = tasks[idx + 1].id
    }
    
    private func previousImage() {
        guard let idx = tasks.firstIndex(where: { $0.id == selectionID }), idx > 0 else { return }
        selectionID = tasks[idx - 1].id
    }
}

// Safe array subscript
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
