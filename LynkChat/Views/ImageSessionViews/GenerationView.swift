//
//  GenerationView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI

struct GenerationView: View {
    @Bindable var generation: Generation
    
    @Namespace private var imageNamespace
    @State private var selectedTaskID: UUID?
    
    // Filter tasks with valid image data
    private var validTasks: [ImageTask] {
        generation.imageTasks.reversed().filter { $0.imageData != nil }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                ForEach(generation.imageTasks.reversed()) { task in
                    GenerationTaskCard(
                        task: task,
                        generation: generation,
                        namespace: imageNamespace,
                        onTap: {
                            if task.imageData != nil {
                                selectedTaskID = task.id
                            }
                        }
                    )
                }
            }
            .padding()
        }
        .fullScreenCover(item: $selectedTaskID) { taskID in
            if let startIndex = validTasks.firstIndex(where: { $0.id == taskID }) {
                ImageTaskModal(
                    tasks: validTasks,
                    startIndex: startIndex,
                    namespace: imageNamespace
                )
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaBar(edge: .bottom) {
            GenerationInputView(generation: generation)
        }
        .navigationTitle(generation.generationMode.rawValue)
        .toolbarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbarTitleMenu {
            Picker("Mode", selection: $generation.generationMode) {
                ForEach(GenerationMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
        }
    }
}

extension UUID: @retroactive Identifiable {
    public var id: Self { self }
}
