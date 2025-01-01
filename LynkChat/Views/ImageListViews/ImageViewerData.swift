//
//  ImageViewerData.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/09/2024.
//

import SwiftUI
import Photos

struct ImageViewerData: View {
    @ObservedObject var imageConfig = ImageModelConfig.shared
    let data: Data
    private let size: CGFloat = 300
    
    @State private var selectedFileURL: URL?
    @State private var isHovering = true
    @State private var showCheckmark = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                if let image = PlatformImage.from(data: data) {
                    Image(platformImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Text("Image Unable to Load")
                        .foregroundStyle(.red)
                        .frame(width: size, height: size)
                }
            }
            .quickLookPreview($selectedFileURL)
            .buttonStyle(.plain)
            
            if isHovering {
                Button(action: saveImage) {
                    Image(systemName: showCheckmark ? "checkmark.circle.fill" : "square.and.arrow.up.circle.fill")
                        .font(.largeTitle)
                        .rotationEffect(.degrees(showCheckmark ? 0 : 180))
                }
                .foregroundStyle(.white, .black.tertiary)
                .buttonStyle(.plain)
                .padding(10)
            }
        }
        #if os(macOS)
        .onHover { isHovering = $0 }
        #endif
    }
    
    func onTap() {
        if let url = FileHelper.createTemporaryURL(for: data) {
            selectedFileURL = url
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
