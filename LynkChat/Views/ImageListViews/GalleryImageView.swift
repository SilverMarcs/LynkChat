//
//  GalleryImageView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/10/2025.
//

import SwiftUI

struct GalleryImageView: View {
    let data: Data?
    @State private var showCheckmark = false
    
    var body: some View {
        if let data, let platformImage = PlatformImage(data: data) {
            Image(platformImage: platformImage)
                .resizable()
                 .scaledToFit()
                 .overlay(alignment: .topTrailing) {
                     Button(action: saveImage) {
                         Image(systemName: showCheckmark ? "checkmark" : "square.and.arrow.down")
                     }
                     .buttonStyle(.glass)
                     .controlSize(.large)
                     .buttonBorderShape(.circle)
                     .padding(10)
                 }
        }
    }
    
    func saveImage() {
        if let data = data {
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
}
