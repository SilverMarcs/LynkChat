//
//  GenerationInputMenu.swift
//  LynkChat
//
//  Created on 26/10/2025.
//

import SwiftUI
import PhotosUI

struct GenerationInputMenu: View {
    var generation: Generation
    
    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    @State private var isFilePickerPresented: Bool = false
    @State private var addingPhoto: Bool = false

    var body: some View {
        Menu {
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
                #if os(macOS)
                    .controlSize(.small)
                    .padding(8)
                    .glassEffect()
                #endif
            }
        }
        .menuStyle(.button)
        .buttonStyle(.glass)
        .controlSize(.large)
        .buttonBorderShape(.circle)
        .menuIndicator(.hidden)
        .fixedSize()
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, matching: .images)
        .task(id: selectedPhotos) {
            guard !selectedPhotos.isEmpty else { return }
            
            addingPhoto = true
            defer { addingPhoto = false }
            
            // Take first selected photo
            if let firstItem = selectedPhotos.first {
                do {
                    if let data = try await firstItem.loadTransferable(type: Data.self) {
                        generation.inputImage = data
                        generation.generationMode = .edit
                    }
                } catch {
                    print("Failed to load photo: \(error)")
                }
            }
            
            selectedPhotos.removeAll()
        }
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                
                Task {
                    addingPhoto = true
                    defer { addingPhoto = false }
                    
                    do {
                        let _ = url.startAccessingSecurityScopedResource()
                        defer { url.stopAccessingSecurityScopedResource() }
                        
                        let data = try Data(contentsOf: url)
                        generation.inputImage = data
                        generation.generationMode = .edit
                    } catch {
                        print("Failed to load file: \(error)")
                    }
                }
            case .failure(let error):
                print("File picker error: \(error)")
            }
        }
    }
}
