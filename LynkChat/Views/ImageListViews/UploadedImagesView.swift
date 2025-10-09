//
//  UploadedImagesView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/10/2025.
//

import SwiftUI

struct UploadedImagesView: View {
    @Bindable var session: ImageSession
    private let spacing: CGFloat = 10
    private let size: CGFloat = 150
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !session.uploadedImages.isEmpty {
                HStack {
                    Text("Uploaded Images")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button(role: .destructive) {
                        session.clearUploadedImages()
                    } label: {
                        Label("Clear All", systemImage: "trash")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: spacing) {
                        ForEach(Array(session.uploadedImages.enumerated()), id: \.offset) { index, imageData in
                            ZStack(alignment: .topTrailing) {
                                ImageViewerData(data: imageData, enableSave: false, size: size)
                                
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
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
            } else if session.config.mode == .editing && session.imageGenerations.isEmpty {
                // Show hint for editing mode when no images uploaded
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)
                    Text("Tip: Upload images using the photo button to start editing")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .listRowSeparator(.hidden)
    }
}
