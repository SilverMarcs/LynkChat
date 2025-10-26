//
//  ImageTaskModal.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/10/2025.
//

import SwiftUI

struct ImageTaskModal: View {
    let tasks: [ImageTask]
    let startIndex: Int
    let namespace: Namespace.ID
    
    @State private var currentIndex: Int
    
    init(tasks: [ImageTask], startIndex: Int, namespace: Namespace.ID) {
        self.tasks = tasks
        self.startIndex = min(max(0, startIndex), max(0, tasks.count - 1))
        self.namespace = namespace
        self._currentIndex = State(initialValue: self.startIndex)
    }
    
    private var currentTask: ImageTask? {
        tasks[safe: currentIndex]
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
        TabView(selection: $currentIndex) {
            ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                if let imageData = task.imageData,
                   let platformImage = PlatformImage.from(data: imageData) {
                    Image(platformImage: platformImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .zoomable()
                        .tag(index)
#if !os(macOS)
                        .matchedTransitionSource(id: task.id, in: namespace)
#endif
                }
            }
        }
        .ignoresSafeArea()
        .tabViewStyle(.page)
        .overlay(alignment: .topTrailing) {
            SaveImageButton(data: currentTask?.imageData)
                .padding()
        }
#if !os(macOS)
        .navigationTransition(.zoom(sourceID: currentTask?.id ?? UUID(), in: namespace))
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
        guard currentIndex < tasks.count - 1 else { return }
        currentIndex += 1
    }
    
    private func previousImage() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }
}

// Safe array subscript
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
