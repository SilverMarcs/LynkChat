//
//  ToolImageView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI
import TipKit

struct ToolImageView: View {
    var imageResult: ImageToolResult?
    
    var body: some View {
        if let toolResult = imageResult {
            FlowLayout(spacing: 8) {
                ForEach(toolResult.images, id: \.id) { imageResult in
                    // Safely unwrap the decoded imageData
                    if let imageData = imageResult.imageData {
                        ImageViewerData(data: imageData)
                    }
//                       let platformImage = PlatformImage.from(data: imageData) {
//                        Image(platformImage: platformImage)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(maxWidth: 300, maxHeight: 300)
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .overlay(alignment: .topTrailing) {
//                                Button(action: { saveImage(for: imageResult) }) {
//                                    Image(systemName: "square.and.arrow.down")
//                                        .resizable()
//                                        .frame(width: 15, height: 15)
//                                }
//                                .buttonStyle(.glass) // .glass is not standard, using .borderedProminent
//                                .buttonBorderShape(.circle)
//                                .controlSize(.extraLarge)
//                                .padding(10)
//                            }
//                    }
                }
            }
        } else {
            ToolImagePlaceholderView()
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

struct ToolImagePlaceholderView: View {
    var body: some View {
        ProgressView()
            .frame(width: 300, height: 300)
            .background(.background.secondary, in: .rect(cornerRadius: 10))
    }
}

#Preview {
    ToolImageView(imageResult: nil)
        .padding()
}
