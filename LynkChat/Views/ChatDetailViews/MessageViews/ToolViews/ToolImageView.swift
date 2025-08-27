//
//  ToolImageView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI
import TipKit

struct ToolImageView: View {
    var imageResult: ImageGenerationResult?
    
    var body: some View {
        if let toolResult = imageResult {
            FlowLayout {
                ForEach(toolResult.images, id: \.id) { imageResult in
                    if let imageData = imageResult.imageData {
                        ImageViewerData(data: imageData)
                    }
                }
            }
        } else {
            ProgressView()
                .frame(width: 300, height: 300)
                .background(.background.secondary, in: .rect(cornerRadius: 10))
        }
    }
    
    func saveImage(for imageResult: ImageResult) {
        if let imageData = imageResult.imageData {
            ImageSaveUtil.saveImage(data: imageData) { success in
                // Optionally handle success/failure, e.g., show a toast message
            }
        }
    }
}

#Preview {
    ToolImageView(imageResult: nil)
        .padding()
}
