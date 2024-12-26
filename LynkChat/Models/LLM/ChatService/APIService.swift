//
//  APIService.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/12/2024.
//

import Foundation

struct APIService: AIService {
    static func refreshModels(provider: String) async -> [GenericModel] {
        guard let request = makeRequest(path: "/chat/models?provider=\(provider)") else {
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let models = try JSONDecoder().decode([APIModel].self, from: data)
            
            return models
                .map { GenericModel(code: $0.id, name: $0.name) }
                .sorted { $0.name < $1.name }
            
        } catch {
            print("Error fetching models: \(error)")
            return []
        }
    }
    
    static func nonStreamingResponse(from request: APIRequest) async throws -> APIResponse {
        guard var urlRequest = makeRequest(path: "/chat", method: "POST") else {
            throw URLError(.badURL)
        }
        
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
        if let rawResponseString = String(data: data, encoding: .utf8) {
            print("Raw Response Data:")
            print(rawResponseString)
        }
        
        do {
            let response = try JSONDecoder().decode(APIResponse.self, from: data)
            return APIResponse(
                text: response.text,
                usage: .init(promptTokens: response.usage.promptTokens, completionTokens: response.usage.completionTokens)
            )
        } catch {
            // Try to decode as error response
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw RuntimeError(errorResponse.error.details)
            }
            
            throw error
        }
    }
    
    static func streamResponse(from request: APIRequest) -> AsyncThrowingStream<StreamResponse, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    guard var urlRequest = makeRequest(path: "/chat", method: "POST") else {
                        throw URLError(.badURL)
                    }
                    
                    urlRequest.httpBody = try JSONEncoder().encode(request)
                    
                    let (result, response) = try await URLSession.shared.bytes(for: urlRequest)
                    
                    // Check if we received an error response
                    if let httpResponse = response as? HTTPURLResponse,
                       !(200...299).contains(httpResponse.statusCode) {
                        // Collect the error response data
                        var errorData = Data()
                        for try await byte in result {
                            errorData.append(byte)
                        }
                        
                        // Try to decode the error response
                        if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: errorData) {
                            throw RuntimeError(errorResponse.error.details)
                        }
                        
                        // If error response decoding fails, throw generic error
                        throw RuntimeError("Server error: \(httpResponse.statusCode)")
                    }
                    
                    for try await line in result.lines {
                        if line.isEmpty { continue }
                        
                        if let data = line.data(using: .utf8),
                           let response = try? JSONDecoder().decode(StreamChunk.self, from: data) {
                            
                            switch response.type {
                            case "text":
                                if let content = response.content {
                                    continuation.yield(.text(content))
                                }
                                
                            case "finish":
                                if let usage = response.usage {
                                    let tokenUsage = TokenUsage(
                                        promptTokens: usage.promptTokens,
                                        completionTokens: usage.completionTokens
                                    )
                                    continuation.yield(.usage(tokenUsage))
                                }
                                
                            case "error":
                                // Handle streaming errors
                                if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                                    throw RuntimeError(errorResponse.error.details)
                                }
                                
                            default:
                                continue
                            }
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private static func makeRequest(path: String, method: String = "GET") -> URLRequest? {
        guard let url = URL(string: "\(AppConfig.shared.myApiHost)\(path)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(AppConfig.shared.myApiKey, forHTTPHeaderField: "x-api-key")
        
        if method == "POST" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
}
