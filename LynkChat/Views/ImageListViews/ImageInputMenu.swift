//
//  ImageInputMenu.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/10/2025.
//

import SwiftUI
import PhotosUI

struct ImageInputMenu: View {
    @Bindable var session: ImageSession
    
    @State private var isFilePickerPresented: Bool = false
    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    
    @State var addingPhoto: Bool = false
    
    var body: some View {
        Menu {
            Group {
                Section {
                    Button {
                        Task {
                            // Get the most recent generation's prompt (if any) and regenerate
                            if let latest = session.imageGenerations.sorted(by: { $0.date < $1.date }).last {
                                // copy prompt from the generation's config to session prompt
                                await session.send(latest.config.prompt)
                            }
                        }
                    } label: {
                        Label("Regenerate", systemImage: "arrow.clockwise")
                    }
                    .disabled(session.imageGenerations.isEmpty)
                }
                
                if session.config.mode == .editing {
                    #if !os(macOS)
                    Button {
//                        config.showCamera = true
                    } label: {
                        Label("Open Camera", systemImage: "camera")
                    }
                    #endif
                    
                    Button {
                        showPhotosPicker = true
                    } label: {
                        Label("Photos Library", systemImage: "photo.on.rectangle.angled")
                    }
                    
                    Button {
                        isFilePickerPresented = true
                    } label: {
                        Label("Attach Files", systemImage: "paperclip")
                    }
                }
            }
            .labelStyle(.titleAndIcon)
        } label: {
            if !addingPhoto {
#if os(macOS)
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.secondary, .clear)
                    .font(.largeTitle).fontWeight(.semibold)
                    .glassEffect()
#else
                Image(systemName: "plus")
#endif
            } else {
                ProgressView()
                    .controlSize(.small)
                    .padding(8)
                    .glassEffect()
            }
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, matching: .images)
        .task(id: selectedPhotos) {
            guard !selectedPhotos.isEmpty else { return }
            addingPhoto = true
            
            for item in selectedPhotos {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    session.addUploadedImage(data)
                }
            }
            
            selectedPhotos.removeAll()
            addingPhoto = false
        }
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                Task {
                    addingPhoto = true
                    for url in urls {
                        guard url.startAccessingSecurityScopedResource() else {
                            print("Failed to access security scoped resource for: \(url.lastPathComponent)")
                            continue
                        }
                        
                        if let data = try? Data(contentsOf: url) {
                            session.addUploadedImage(data)
                        }
                        
                        url.stopAccessingSecurityScopedResource()
                    }
                    addingPhoto = false
                }
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }
}
