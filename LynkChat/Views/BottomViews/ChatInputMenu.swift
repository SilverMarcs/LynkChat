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
    
    @ObservedObject var config = AppConfig.shared
    
    @State private var isFilePickerPresented: Bool = false
    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    
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
                
                if chat.config.model.supportedTypes.contains(.image) {
                    Button {
                        showPhotosPicker = true
                    } label: {
                        Label("Photos Library", systemImage: "photo.on.rectangle.angled")
                    }
                }
                
                Button {
                    isFilePickerPresented = true
                } label: {
                    Label("Attach Files", systemImage: "paperclip")
                }
            }
            .labelStyle(.titleAndIcon)
        } label: {
            Image(systemName: "plus.circle.fill")
                #if os(macOS)
//                 .font(.system(size: 20, weight: .regular))
                .font(.title).fontWeight(.semibold)
                #else
                .font(.system(size: 31, weight: .semibold))
//                .font(.system(size: 33, weight: .regular))
                #endif
                .foregroundStyle(.secondary, .quinary)
            
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, matching: .images)
        .task(id: selectedPhotos) {
            do {
                try await chat.inputManager.loadTransferredPhotos(from: selectedPhotos)
            } catch {
                chat.errorMessage = "Failed to load transferred photos. Error: \(error)"
            }
            selectedPhotos.removeAll()
        }
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: Array(chat.config.model.supportedTypes),
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
