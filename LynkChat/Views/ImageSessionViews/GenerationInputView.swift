//
//  GenerationInputView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/10/2025.
//

import SwiftUI

struct GenerationInputView: View {
    @Bindable var generation: Generation
    
    @FocusState private var isFocused: FocusedField?
    
    var body: some View {
        HStack(spacing: 5) {
            if let imageData = generation.inputImageData {
                ImageViewerData(data: imageData, enableSave: false, size: 35)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            generation.inputImageData = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .foregroundStyle(.white)
                        .padding(-5)
                    }
            } else {
                GenerationInputMenu(generation: generation)
            }
            
            HStack() {
                TextField(generation.generationMode == .edit ? "Edit prompt..." : "Generate prompt...", text: $generation.prompt, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 14)
                    .focused($isFocused, equals: .imageInput)
                
                Button {
                    handleSubmit()
                } label: {
                    Image(systemName: "sparkles")
                }
                .disabled(generation.prompt.isEmpty || !canSubmit)
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .padding(.trailing, 5)
            }
            .padding(.vertical, 6.5)
            .glassEffect(in: .rect(cornerRadius: 30))
        }
        .padding(.horizontal, isFocused == nil ? 20 : 10)
        .padding(.vertical, isFocused == nil ? -5 : 10)
    }
    
    private var canSubmit: Bool {
        if generation.generationMode == .edit {
            return generation.inputImageData != nil
        }
        return true
    }
    
    private func handleSubmit() {
        generation.queueTask()
        isFocused = nil
    }
}
