//
//  GenerationView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftMediaViewer

struct GenerationView: View {
    @Bindable var generation: Generation
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                ForEach(generation.imageTasks.reversed()) { task in
                    GenerationTaskCard(task: task, generation: generation)
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
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
