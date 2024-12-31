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
    
    init(dataFiles: [TypedData], onDelete: ((TypedData) -> Void)? = nil) {
        self.dataFiles = dataFiles
        self.onDelete = onDelete
    }
    
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(dataFiles) { file in
                fileItemView(for: file)
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

