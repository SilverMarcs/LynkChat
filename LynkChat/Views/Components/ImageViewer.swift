//
//  ImageViewer.swift
//  LynkChat
//
//  Created by Zabir Raihan on 20/10/2025.
//


import SwiftUI
import Photos
import SwiftMediaViewer

struct ImageViewer: View {
    let url: URL
    var enableSave: Bool = true
    var size: CGFloat = 300
    
    @State private var selectedFileURL: URL?
    @State private var showCheckmark = false
    
    var body: some View {
        SMVImage(url: url, targetSize: 4000)
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: size)
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
        ImageSaveUtil.saveImageFromURL(url: url) { success in
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
