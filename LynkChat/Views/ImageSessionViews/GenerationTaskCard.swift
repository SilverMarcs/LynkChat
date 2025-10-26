//
//  GenerationTaskCard.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/10/2025.
//

import SwiftUI
import SwiftMediaViewer

struct GenerationTaskCard: View {
    let task: ImageTask
    @Bindable var generation: Generation
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(spacing: 8) {
                if let imageData = task.imageData {
                    SMVImageData(data: imageData)
                        .aspectRatio(9/16, contentMode: .fill)
                } else {
                    // Placeholder when image is loading
                    Color.clear
                        .aspectRatio(9/16, contentMode: .fit)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.background.secondary)
            }
            .overlay {
                if task.isProcessing {
                    ProgressView()
                }
            }
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.1),
                        .black.opacity(0.3),
                        .black.opacity(0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 60)
                .overlay(alignment: .bottomLeading) {
                    Text(task.prompt)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .padding(10)
                }
            }
        }
        .clipShape(.rect(cornerRadius: 10))
        .contextMenu(menuItems: {
            if task.imageData != nil {
                Button {
                    setAsSource()
                } label: {
                    Label("Set as Source", systemImage: "photo.badge.plus")
                }
            }
            
            Button(role: .destructive) {
                deleteTask()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        })
    }
    
    private func setAsSource() {
        generation.inputImageData = task.imageData
        generation.generationMode = .edit
    }
    
    private func deleteTask() {
        if let index = generation.imageTasks.firstIndex(where: { $0.id == task.id }) {
            let _ = withAnimation {
                generation.imageTasks.remove(at: index)
            }
        }
    }
}
