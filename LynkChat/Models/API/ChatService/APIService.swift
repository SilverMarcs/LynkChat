//
//  APIService.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/12/2024.
//

import Foundation
import UniformTypeIdentifiers

enum APIService {
    static func streamResponse(from request: APIRequest) -> AsyncThrowingStream<ResponseType, Error> {
        AppLogger.warning("Streaming response for model: \(String(describing: request.model))")
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    guard var urlRequest = makeRequest(path: .chat, method: .POST) else {
                        throw URLError(.badURL)
                    }
                    
                    urlRequest.httpBody = try JSONEncoder().encode(request)
                    
                    let (result, response) = try await URLSession.shared.bytes(for: urlRequest)
                    
                    // Check if we received an error response
                    if let httpResponse = response as? HTTPURLResponse,
                       !(200...299).contains(httpResponse.statusCode) {
                        var errorData = Data()
                        for try await byte in result {
                            errorData.append(byte)
                        }
                        
                        AppLogger.critical("Server error response: \(String(data: errorData, encoding: .utf8) ?? "Unable to read error data")")
                        
                        let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: errorData)
                        throw RuntimeError(errorResponse.error)
                    }
                    
                    for try await line in result.lines {
                        if line.isEmpty { continue }
                        
                        AppLogger.debug("\(line)")
                        
                        if let data = line.data(using: .utf8) {
                            do {
                                let response = try JSONDecoder().decode(ResponseType.self, from: data)
                                
                                switch response {
                                case .text(let textResponse):
                                    continuation.yield(.text(textResponse))
                                case .reasoning(let reasoningResponse):
                                    continuation.yield(.reasoning(reasoningResponse))
                                case .reasoningEnd(let reasoningEndResponse):
                                    continuation.yield(.reasoningEnd(reasoningEndResponse))
                                case .toolCall(let toolCallResponse):
                                    continuation.yield(.toolCall(toolCallResponse))
                                case .toolResult(let toolResultResponse):
                                    continuation.yield(.toolResult(toolResultResponse))
                                case .finish(let finishResponse):
                                    continuation.yield(.finish(finishResponse))
                                case .error(let errorResponse):
                                    throw RuntimeError(errorResponse.content)
                                }
                            } catch {
                                AppLogger.error("Decoding error: \(error.localizedDescription)")
                                AppLogger.error("Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                                throw error
                            }
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    AppLogger.error("Stream error: \(error.localizedDescription)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private static func makeRequest(path: APIPath, method: HTTPMethod) -> URLRequest? {
        guard let url = URL(string: "\(String.apiHost)\(path.pathString)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(AppConfig.shared.myApiKey, forHTTPHeaderField: "x-api-key")
        
        if method == .POST && path != .upload {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
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
    
    static func generateTitle(prompt: String) async throws -> String {
        guard var urlRequest = makeRequest(path: .title, method: .POST) else {
            throw URLError(.badURL)
        }
        
        let request = TitleRequest(prompt: prompt)
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // Check response status
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            AppLogger.critical("Title generation error response: \(String(data: data, encoding: .utf8) ?? "Unable to read error data")")
            
            let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw RuntimeError(errorResponse.error)
        }
        
        let titleResponse = try JSONDecoder().decode(TitleResponse.self, from: data)
        return titleResponse.title
    }
}
