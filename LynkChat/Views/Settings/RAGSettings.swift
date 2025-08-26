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
    @State private var uploadedFiles: [RAGResource] = []
    @State private var isLoadingFiles = false
    @State private var errorMessage = ""
    
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
                        .foregroundStyle(uploadMessage.contains("Error") ? .red : .green)
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
            
            Section {
                if isLoadingFiles {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if uploadedFiles.isEmpty {
                    Text("No files uploaded")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(uploadedFiles, id: \.id) { file in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(file.filename)
                                    .font(.headline)
                                
                                Text("Uploaded: \(formatDate(file.createdAt))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(role: .destructive) {
                                deleteFile(id: file.id)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                Text("Uploaded Files \(uploadedFiles.count)")
            } footer: {
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .sectionActions {
                Button("Refresh") {
                    Task { await loadFiles() }
                }
                .disabled(isLoadingFiles)
            }
        }
        .formStyle(.grouped)
        .toolbarTitleDisplayMode(.inline)
        .navigationTitle("Retrieval Augmented Generation")
        .task {
            await loadFiles()
        }
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
                // Refresh the file list after successful upload
                await loadFiles()
            } catch {
                isUploading = false
                uploadMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func loadFiles() async {
        isLoadingFiles = true
        errorMessage = ""
        
        do {
            let response = try await APIService.listFiles()
            uploadedFiles = response.data
            isLoadingFiles = false
        } catch {
            errorMessage = "Failed to load files: \(error.localizedDescription)"
            isLoadingFiles = false
        }
    }
    
    private func deleteFile(id: Int) {
        Task {
            do {
                let _ = try await APIService.deleteFile(id: id)
                await loadFiles()
            } catch {
                errorMessage = "Failed to delete file: \(error.localizedDescription)"
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d, yyyy" // e.g., "Aug 26, 2025"
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    RAGSettings()
}

#Preview {
    RAGSettings()
}
