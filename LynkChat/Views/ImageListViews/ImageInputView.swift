//
//  ImageInputView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI
import PhotosUI
import SwiftMediaViewer

struct ImageInputView: View {
    @Bindable var session: ImageSession
    @FocusState var isFocused: FocusedField?
    
    @State private var showPhotosPicker = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    @State private var isLoadingPhotos = false
    
    var body: some View {
        VStack {
            FlowLayout {
                ForEach(Array(session.uploadedImages.enumerated()), id: \.offset) { index, imageData in
                    SMVImageData(data: imageData)
                        .frame(width: 100, height: 100)
                        .overlay(alignment: .topTrailing) {
                            Button(role: .destructive) {
                                session.removeUploadedImage(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white, .red)
                            }
                            .buttonStyle(.plain)
                            .padding(8)
                        }
                }
            }
            
            HStack {
                ImageInputMenu(session: session)
                
                HStack(spacing: 5) {
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
                .padding(4)
                .glassEffect(in: .rect(cornerRadius: 20))
            }
        }
        .ignoresSafeArea()
        .padding(11)
        #if os(macOS)
        .task {
            isFocused = .imageInput
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Focus") {
                    isFocused = .imageInput
                }
                .keyboardShortcut("l")
                
                Button("Delete Last Message", role: .destructive) {
                    if let last = session.imageGenerations.last {
                        session.deleteGeneration(last)
                    }
                }
                .keyboardShortcut(.delete)
            }
        }
        #endif
    }
    
    private func sendInput() {
        guard !session.prompt.isEmpty else { return }

        Task {
            await session.send()
        }
    }
}

#Preview {
    ImageInputView(session: .mockImageSession)
}
