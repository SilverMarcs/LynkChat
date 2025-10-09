//
//  ImageInputView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI
import PhotosUI

struct ImageInputView: View {
    @Bindable var session: ImageSession
    @FocusState var isFocused: FocusedField?
    
    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    @State private var isLoadingPhotos = false
    
    var body: some View {
        HStack(spacing: 5) {
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
                    .labelStyle(.iconOnly)
                    .tint(.white)
            }
            .disabled(session.imageGenerations.isEmpty)
            .controlSize(.large)
            .fontWeight(.bold)
            .buttonBorderShape(.circle)
            .keyboardShortcut("r")
            
            Button {
                showPhotosPicker = true
            } label: {
                if isLoadingPhotos {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Add Photos", systemImage: "photo.on.rectangle.angled")
                        .labelStyle(.iconOnly)
                        .tint(.white)
                }
            }
            .controlSize(.large)
            .fontWeight(.bold)
            .buttonBorderShape(.circle)
            .disabled(isLoadingPhotos)
            
            TextField("Prompt", text: $session.prompt, axis: .vertical)
                .onSubmit( { sendInput() } )
                .textFieldStyle(.plain)
                .padding(.leading, 6)
                .focused($isFocused, equals: .imageInput)
                .onKeyPress(.upArrow) {
                    if session.prompt.isEmpty {
                        if let lastPrompt = session.imageGenerations.last?.config.prompt {
                            session.prompt = lastPrompt
                            return .handled
                        }
                    }
                    return .ignored
                }
            
            Button(action: sendInput) {
                Image(systemName: "arrow.up")
            }
            .controlSize(.large)
            .fontWeight(.bold)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(4)
        .glassEffect(in: .rect(cornerRadius: 20))
        .ignoresSafeArea()
        .padding(11)
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotos, matching: .images)
        .task(id: selectedPhotos) {
            guard !selectedPhotos.isEmpty else { return }
            isLoadingPhotos = true
            
            for photo in selectedPhotos {
                if let data = try? await photo.loadTransferable(type: Data.self) {
                    session.addUploadedImage(data)
                }
            }
            
            selectedPhotos.removeAll()
            isLoadingPhotos = false
        }
        #if os(macOS)
        .task {
            isFocused = .imageInput
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Focus") {
                    isFocused = .imageInput
                }
                .keyboardShortcut("l")
            }
        }
        #endif
    }
    
    private func sendInput() {
        guard !session.prompt.isEmpty else { return }
        
        #if !os(macOS)
        isFocused = nil
        #endif
        Task {
            await session.send()
        }
    }
    
    var imageSize: CGFloat {
        #if os(macOS)
        21
        #else
        31
        #endif
    }
}

#Preview {
    ImageInputView(session: .mockImageSession)
}
