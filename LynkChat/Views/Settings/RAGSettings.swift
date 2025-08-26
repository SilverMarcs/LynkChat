//
//  RAGSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/08/2025.
//

import SwiftUI

struct RAGSettings: View {
    @State private var selectedFile: URL?
    @State private var isUploading = false
    @State private var uploadMessage = ""
    @State private var showingFilePicker = false
    
    var body: some View {
        Form {
            Section {
                if let file = selectedFile {
                    LabeledContent {
                        Button("Remove") {
                            selectedFile = nil
                        }
                    } label: {
                        Text(file.lastPathComponent)
                    }
                } else {
                    Text("No file selected")
                }
            } header: {
                Text("Upload Files")
            } footer: {
                if !uploadMessage.isEmpty {
                    Text(uploadMessage)
                }
            }
            .sectionActions {
                Button("Choose File") {
                    showingFilePicker = true
                }
                .disabled(isUploading)
                
                Button(isUploading ? "Uploading.." : "Upload") {
                    uploadFile()
                }
                .disabled(selectedFile == nil || isUploading)
            }
        }
        .formStyle(.grouped)
        .toolbarTitleDisplayMode(.inline)
        .navigationTitle("Retrieval Augmented Generation")
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedFile = url
                }
            case .failure(let error):
                uploadMessage = "Error selecting file: \(error.localizedDescription)"
            }
        }
    }
    
    private func uploadFile() {
        guard let file = selectedFile else { return }
        
        isUploading = true
        
        Task {
            do {
                let _ = try await APIService.uploadFile(file)
                isUploading = false
                uploadMessage = "Upload successful!"
                selectedFile = nil
            } catch {
                isUploading = false
                uploadMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    RAGSettings()
}
