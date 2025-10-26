//
//  GenerationTaskCard.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/10/2025.
//

import SwiftUI

struct GenerationTaskCard: View {
    let task: ImageTask
    var generation: Generation
    let namespace: Namespace.ID
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if let imageData = task.imageData, let platformImage = PlatformImage.from(data: imageData)  {
                    Image(platformImage: platformImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.background.secondary)
                        .aspectRatio(9/16, contentMode: .fit)
                }
            }
            .overlay {
                if task.isProcessing {
                    ProgressView()
                } else if task.error != nil {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .imageScale(.large)
                }
            }
            #if !os(macOS)
            .matchedTransitionSource(id: task.id, in: namespace)
            #endif
        }
        .clipShape(.rect(cornerRadius: 10))
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .contextMenu {
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
        } preview: {
            VStack {
                if let imageData = task.imageData, let platformImage = PlatformImage.from(data: imageData)  {
                    Image(platformImage: platformImage)
                        .resizable()
                }
                
                Text(task.prompt)
                    .font(.subheadline)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
        }
    }
    
    private func setAsSource() {
        generation.inputImage = task.imageData
        generation.config.mode = .edit
    }
    
    private func deleteTask() {
        if let index = generation.imageTasks.firstIndex(where: { $0.id == task.id }) {
            let _ = withAnimation {
                generation.imageTasks.remove(at: index)
            }
        }
    }
}
