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
    @State private var showConfigSheet = false
    
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
            ImageTaskModal(
                tasks: validTasks,
                selectedID: taskID,
                namespace: imageNamespace
            )
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showConfigSheet = true
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        .sheet(isPresented: $showConfigSheet) {
            ImageConfigSheet(
                config: $generation.imageConfig,
                mode: $generation.generationMode
            )
            .presentationDetents([.medium])
        }
    }
}

extension UUID: @retroactive Identifiable {
    public var id: Self { self }
}
