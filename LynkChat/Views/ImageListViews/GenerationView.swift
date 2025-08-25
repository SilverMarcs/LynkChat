//
//  GenerationView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI

struct GenerationView: View {
    @ObservedObject var imageConfig = ImageModelConfig.shared
    var generation: Generation
    private let spacing: CGFloat = 10
    private let size: CGFloat = 300
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()

                if generation.state == .generating {
                    ActionButton(isStop: true) {
                        generation.stopGenerating()
                    }
                }
                
                GroupBox {
                    Text(generation.config.prompt)
                        .textSelection(.enabled)
                        #if os(macOS)
                        .padding(5)
                        #endif
                }
                .groupBoxStyle(PlatformGroupBox())
            }
            
            
            VStack(alignment: .leading) {
                AssistantLabel(model: generation.config.model)
                    .padding(.bottom, 4)
                
                if generation.state == .error {
                    Text(generation.errorMessage)
                        .foregroundStyle(.white)
                        .textSelection(.enabled)
                        .foregroundStyle(.red)
                        .padding(.leading, 5)
                        .padding(.top, 1)

                } else {
                    LazyVGrid(columns: gridColumns, alignment: .leading, spacing: spacing) {
                        if generation.state == .generating {
                            ForEach(1 ... generation.config.numImages, id: \.self) { image in
                                ProgressView()
                                    .frame(width: size, height: size)
                                    .background(.background.secondary, in: .rect(cornerRadius: 15))
                            }
                        } else if generation.state == .success {
                            ForEach(generation.images, id: \.self) { image in
                                ImageViewerData(data: image)
                                    .backgroundExtensionEffect()
                            }
                        }
                    }
                }
            }
        }
        .contentShape(.rect)
        .contextMenu {
            Button {
                generation.config.prompt.copyToPasteboard()
            } label: {
                Label("Copy Prompt", systemImage: "document.on.clipboard")
            }
            
            Button(role: .destructive) {
                generation.deleteSelf()
            } label: {
                Label("Delete Generation", systemImage: "trash")
            }
        }
    }
    
    private var gridColumns: [GridItem] {
        #if os(iOS)
        [GridItem(.fixed(size), spacing: spacing)]
        #else
        [GridItem(.fixed(size), spacing: spacing),
        GridItem(.fixed(size), spacing: spacing)]
        #endif
    }
}


#Preview {
    GenerationView(generation: .mockGeneration)
}
