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
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 8)
                ], spacing: 8) {
                    ForEach(imageFiles) { file in
                        fileItemView(for: file)
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
            
            if !nonImageFiles.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(nonImageFiles) { file in
                        fileItemView(for: file)
                    }
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
                Button {
                    onDelete(typedData)
                } label: {
                    Label("Remove", systemImage: "xmark.circle.fill")
                        #if !os(macOS)
                        .padding(10)
                        .contentShape(.rect)
                        #endif
                }
                .padding(3)
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .shadow(radius: 5)
            }
        }
    }
    
    func fileView(for typedData: TypedData) -> some View {
        Button {
            if let url = FileHelper.createTemporaryURL(for: typedData) {
                selectedFileURL = url
            }
        } label: {
            if typedData.fileType.conforms(to: .image) {
                ImageViewer(typedData: typedData)
            } else {
                FileViewer(typedData: typedData)
            }
        }
        .buttonStyle(.plain)
    }
}

