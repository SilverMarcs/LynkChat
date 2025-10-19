//
//  ImageViewerData.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/09/2024.
//

import SwiftUI
import Photos
import SwiftMediaViewer

struct ImageViewerData: View {
    let data: Data
    var enableSave: Bool = true
    var size: CGFloat = 300
    
    @State private var selectedFileURL: URL?
    @State private var showCheckmark = false
    
    var body: some View {
        SMVImageData(data: data)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(.rect(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                if enableSave {
                    Button(action: saveImage) {
                        Image(systemName: showCheckmark ? "checkmark" : "square.and.arrow.down")
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .controlSize(.extraLarge)
                    .padding(10)
            }
        }
    }

    func saveImage() {
        ImageSaveUtil.saveImage(data: data) { success in
            if success {
                DispatchQueue.main.async {
                    showCheckmark = true
                    
                    // Revert back to the original icon after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showCheckmark = false
                    }
                }
            }
        }
    }
}
