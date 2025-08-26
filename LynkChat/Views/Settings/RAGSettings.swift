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
        VStack(spacing: 20) {
            Text("RAG File Upload")
                .font(.headline)
            
            VStack(spacing: 12) {
                if let file = selectedFile {
                    HStack {
                        Text(file.lastPathComponent)
                        Spacer()
                        Button("Remove") {
                            selectedFile = nil
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button("Choose File") {
                    showingFilePicker = true
                }
                .disabled(isUploading)
                
                Button("Upload") {
                    uploadFile()
                }
                .disabled(selectedFile == nil || isUploading)
                
                if !uploadMessage.isEmpty {
                    Text(uploadMessage)
                        .foregroundColor(uploadMessage.contains("Error") ? .red : .green)
                }
            }
            
            Spacer()
        }
        .padding()
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
        uploadMessage = "Uploading..."
        
        Task {
            do {
                let response = try await APIService.uploadFile(file)
                await MainActor.run {
                    isUploading = false
                    uploadMessage = "Upload successful!"
                    selectedFile = nil
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    uploadMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    RAGSettings()
}
