//
//  ImageSessionInputMenu.swift
//  LynkChat
//
//  Created by GitHub Copilot on 11/10/2025.
//

import SwiftUI
import PhotosUI

struct ImageSessionInputMenu: View {
    @Bindable var session: ImageSession
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
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, matching: .images)
        .task(id: selectedPhotos) {
            guard !selectedPhotos.isEmpty else { return }
            addingPhoto = true
            do {
                for item in selectedPhotos {
                    if let data = try await item.loadTransferable(type: Data.self) {
                        session.inputImages.append(data)
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
                            session.inputImages.append(data)
                        }
                    }
                }
            case .failure:
                break
            }
        }
    }
}

#Preview {
    ImageSessionInputMenu(session: .mockImageSession)
}
