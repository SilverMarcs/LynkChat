//
//  DataFileView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/08/2024.
//

import SwiftUI
import QuickLook
import UniformTypeIdentifiers

struct DataFilesView: View {
    let dataFiles: [TypedData]
    var onDelete: ((TypedData) -> Void)? = nil
    
    @State private var selectedFileURL: URL?
    
    private var imageFiles: [TypedData] {
        dataFiles.filter { $0.fileType.conforms(to: .image) }
    }
    
    private var nonImageFiles: [TypedData] {
        dataFiles.filter { !$0.fileType.conforms(to: .image) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !imageFiles.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(imageFiles) { file in
                        fileItemView(for: file)
                    }
                }
                .padding(.trailing, -8)
            }
            
            GlassEffectContainer {
                if !nonImageFiles.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(nonImageFiles) { file in
                            fileItemView(for: file)
                        }
                    }
                    .padding(.trailing, -8)
                }
            }
        }
        .quickLookPreview($selectedFileURL)
    }
    
    @ViewBuilder
    private func fileItemView(for typedData: TypedData) -> some View {
        ZStack(alignment: .topTrailing) {
            fileView(for: typedData)
            
            if let onDelete {
                Button(role: .destructive) {
                    onDelete(typedData)
                } label: {
                    Label("Remove", systemImage: "xmark")
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .labelStyle(.iconOnly)
                .padding(3)
            }
        }
    }
    
    @ViewBuilder
    func fileView(for typedData: TypedData) -> some View {
        if typedData.fileType.conforms(to: .image) {
            Button {
                if let url = FileHelper.createTemporaryURL(for: typedData) {
                    selectedFileURL = url
                }
            } label: {
                ImageViewer(typedData: typedData)
            }
            .buttonStyle(.plain)
        } else {
            Button {
                if let url = FileHelper.createTemporaryURL(for: typedData) {
                    selectedFileURL = url
                }
            } label: {
                FileViewer(typedData: typedData)
            }
            .buttonStyle(.glass)
        }
    }
}

