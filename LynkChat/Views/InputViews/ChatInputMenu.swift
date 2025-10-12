//
//  ChatInputMenu.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI
import PhotosUI

struct ChatInputMenu: View {
    @Bindable var chat: Chat
    
    var config = AppSettings.shared
    
    @State private var isFilePickerPresented: Bool = false
    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    @State var addingPhoto: Bool = false
    
    var body: some View {
        Menu {
            Group {
                #if !os(macOS)
                Section {
                    Button {
                        guard !chat.isReplying, let lastMessage = chat.currentThread.last else { return }
                        
                        chat.resetContext(at: lastMessage)
                    } label: {
                        Label("Reset Context", systemImage: "eraser")
                    }
                }
            
                Button {
                    config.showCamera = true
                } label: {
                    Label("Open Camera", systemImage: "camera")
                }
                #endif
                
                // TODO: fix
//                if chat.config.model.supportedTypes.contains(.image) {
                    Button {
                        showPhotosPicker = true
                    } label: {
                        Label("Photos Library", systemImage: "photo.on.rectangle.angled")
                    }
//                }
                
                Button {
                    isFilePickerPresented = true
                } label: {
                    Label("Attach Files", systemImage: "paperclip")
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
            guard !selectedPhotos.isEmpty else { return }  // Skip if no photos selected (e.g., on first appearance)
            addingPhoto = true
            do {
                try await chat.inputManager.loadTransferredPhotos(from: selectedPhotos)
            } catch {
                chat.errorMessage = "Failed to load transferred photos. Error: \(error)"
            }
            selectedPhotos.removeAll()
            addingPhoto = false
        }
        .fileImporter(
            isPresented: $isFilePickerPresented,
            // TODO: fix
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                Task {
                    for url in urls {
                        guard url.startAccessingSecurityScopedResource() else {
                            print("Failed to access security scoped resource for: \(url.lastPathComponent)")
                            continue
                        }
                        
                        do {
                            try await chat.inputManager.processFile(at: url)
                        } catch {
                            chat.errorMessage = "Failed to process file: \(url.lastPathComponent). Error: \(error)"
                        }
                        
                        url.stopAccessingSecurityScopedResource()
                    }
                }
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ChatInputMenu(chat: .mockChat)
}
