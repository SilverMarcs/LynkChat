//
//  ImageViewerData.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/09/2024.
//

import SwiftUI
import Photos

struct ImageViewerData: View {
    let data: Data
    var enableSave: Bool = true
    var size: CGFloat = 300
    
    @State private var selectedFileURL: URL?
    @State private var showCheckmark = false
    
    var body: some View {
        if let platformImage = PlatformImage.from(data: data) {
              Image(platformImage: platformImage)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .topTrailing) {
                if enableSave {
                    Button(action: saveImage) {
                        Image(systemName: showCheckmark ? "checkmark.circle.fill" : "square.and.arrow.up.circle.fill")
                            .font(.largeTitle)
                            .rotationEffect(.degrees(showCheckmark ? 0 : 180))
                            .foregroundStyle(.primary, .clear)
                            .glassEffect(in: .circle)
                    }
                    .padding(10)
                    
                }
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
