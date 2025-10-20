//
//  EditGenerationView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 13/10/2025.
//

import SwiftUI
import PhotosUI

struct EditGenerationView: View {
    @Bindable var generation: Generation
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    @State private var isFilePickerPresented = false
    @State private var addingPhoto = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Current Images") {
                    if !generation.inputImages.isEmpty {
                        FlowLayout {
                            ForEach(generation.inputImages, id: \.self) { image in
                                ImageViewerData(data: image, enableSave: false, size: 100)
                                    .overlay(alignment: .topTrailing) {
                                        Button {
                                            if let index = generation.inputImages.firstIndex(of: image) {
                                                generation.inputImages.remove(at: index)
                                            }
                                        } label: {
                                            Image(systemName: "xmark")
                                        }
                                        .padding(5)
                                        .buttonStyle(.glass)
                                        .buttonBorderShape(.circle)
                                        .controlSize(.small)
                                    }
                            }
                        }
                    }
                    
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
                            Label("Add Photos", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                                .contentShape(.rect)
                        } else {
                            ProgressView()
                        }
                    }
                    .menuStyle(.button)
                    .buttonSizing(.flexible)
                }
                
                Section {
                    Picker("Mode", selection: $generation.session.config.mode) {
                        ForEach(GenerationMode.allCases) { mode in
                            Text(mode.rawValue)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Prompt") {
                    TextField("Enter new prompt", text: $generation.config.prompt)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        // inputImages are already set
                        generation.imageURLs = []
                        //                    generation.mode = .editing
                        Task { await generation.send() }
                        dismiss()
                    }
                }
            }
            .navigationTitle("Editing Generation")
            .toolbarTitleDisplayMode(.inline)
            .formStyle(.grouped)
            .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, matching: .images)
            .task(id: selectedPhotos) {
                guard !selectedPhotos.isEmpty else { return }
                addingPhoto = true
                do {
                    for item in selectedPhotos {
                        if let data = try await item.loadTransferable(type: Data.self) {
                            generation.inputImages.append(data)
                        }
                    }
                } catch {
                    // Swallow errors for now; can surface in UI if needed
                }
                selectedPhotos.removeAll()
                addingPhoto = false
            }
            .fileImporter(
                isPresented: $isFilePickerPresented,
                allowedContentTypes: [.item],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    Task {
                        for url in urls {
                            guard url.startAccessingSecurityScopedResource() else { continue }
                            defer { url.stopAccessingSecurityScopedResource() }
                            if let data = try? Data(contentsOf: url) {
                                generation.inputImages.append(data)
                            }
                        }
                    }
                case .failure:
                    break
                }
            }
        }
    }
}


#Preview {
    GenerationView(generation: .mockGeneration)
}
