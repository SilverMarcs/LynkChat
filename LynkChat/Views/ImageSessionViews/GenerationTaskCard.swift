//
//  GenerationTaskCard.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/10/2025.
//

import SwiftUI

struct GenerationTaskCard: View {
    let task: ImageTask
    @Bindable var generation: Generation
    let namespace: Namespace.ID
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if let imageData = task.imageData, let platformImage = PlatformImage.from(data: imageData)  {
                    Image(platformImage: platformImage)
                        .resizable()
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.background.secondary)
                }
            }
            .aspectRatio(9/16, contentMode: .fit)
#if !os(macOS)
            .matchedTransitionSource(id: task.id, in: namespace)
#endif
            .overlay {
                if task.isProcessing {
                    ProgressView()
                }
            }
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.3),
                        .black.opacity(0.6)
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
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .contextMenu(menuItems: {
            Section {
                Button {
                    task.prompt.copyToPasteboard()
                } label: {
                    Label("Copy Prompt", systemImage: "document.on.clipboard")
                }
                
                if task.imageData != nil {
                    Button {
                        setAsSource()
                    } label: {
                        Label("Set as Source", systemImage: "photo.badge.plus")
                    }
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
