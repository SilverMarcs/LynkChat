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
    
    @State private var isFocused: Bool = false

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
        .navigationTitle(generation.config.mode.rawValue)
        .toolbarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbarTitleMenu {
            Picker("Mode", selection: $generation.config.mode) {
                ForEach(GenerationMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .searchable(text: $generation.prompt, isPresented: $isFocused, prompt: "Generate or Edit Images")
        .onSubmit(of: .search) {
            guard !generation.prompt.isEmpty else { return }
            generation.queueTask()
        }
        .toolbar {
              ToolbarItem(placement: .bottomBar) {
                  GenerationInputMenu(generation: generation)
              }
              .sharedBackgroundVisibility(generation.inputImage == nil ? .visible : .hidden)
              
              ToolbarSpacer(.fixed, placement: .bottomBar)
              
              DefaultToolbarItem(kind: .search, placement: .bottomBar)

              ToolbarSpacer(.fixed, placement: .bottomBar)
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
        #if os(macOS)
        .safeAreaBar(edge: .bottom) {
            GenerationInputView(generation: generation)
        }
        #endif
        .sheet(isPresented: $showConfigSheet) {
            ImageConfigSheet(generation: generation)
                .presentationDetents([.medium])
        }
    }
}

extension UUID: @retroactive Identifiable {
    public var id: Self { self }
}
