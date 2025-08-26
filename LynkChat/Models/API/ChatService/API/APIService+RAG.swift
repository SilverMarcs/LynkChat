//
//  APIService+RAG.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/08/2025.
//

import Foundation
import UniformTypeIdentifiers

extension APIService {
    static func uploadFile(_ fileURL: URL) async throws -> FileUploadResponse {
        guard var urlRequest = makeRequest(path: .upload, method: .POST) else {
            throw URLError(.badURL)
        }
        
        // Start accessing the security-scoped resource
        guard fileURL.startAccessingSecurityScopedResource() else {
            throw RuntimeError("Unable to access file")
        }
        defer { fileURL.stopAccessingSecurityScopedResource() }
        
        // Read file data
        let fileData = try Data(contentsOf: fileURL)
        let fileName = fileURL.lastPathComponent
        
        // Get MIME type using UTType
        let mimeType: String = {
            if let utType = UTType(filenameExtension: fileURL.pathExtension),
               let preferredMIMEType = utType.preferredMIMEType {
                return preferredMIMEType
            }
            return "application/octet-stream" // fallback for unknown types
        }()
        
        // Create multipart form data
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // Check response status
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            AppLogger.critical("Upload error response: \(String(data: data, encoding: .utf8) ?? "Unable to read error data")")
            
            let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw RuntimeError(errorResponse.error)
        }
        
        return try JSONDecoder().decode(FileUploadResponse.self, from: data)
    }
    
    static func listFiles() async throws -> RAGListResponse {
        guard let urlRequest = makeRequest(path: .list, method: .GET) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // Check response status
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            AppLogger.critical("List files error response: \(String(data: data, encoding: .utf8) ?? "Unable to read error data")")
            
            let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw RuntimeError(errorResponse.error)
        }
        
        return try JSONDecoder().decode(RAGListResponse.self, from: data)
    }
    
    static func deleteFile(id: Int) async throws -> RAGDeleteResponse {
        guard var urlRequest = makeRequest(path: .delete, method: .DELETE) else {
            throw URLError(.badURL)
        }
        
        // Add query parameter for the resource ID
        if let url = urlRequest.url,
           var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            urlComponents.queryItems = [URLQueryItem(name: "id", value: String(id))]
            urlRequest.url = urlComponents.url
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // Check response status
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            AppLogger.critical("Delete file error response: \(String(data: data, encoding: .utf8) ?? "Unable to read error data")")
            
            let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw RuntimeError(errorResponse.error)
        }
        
        return try JSONDecoder().decode(RAGDeleteResponse.self, from: data)
    }
}
