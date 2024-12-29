//
//  APIService.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/12/2024.
//

import Foundation

struct APIService {
    static func nonStreamingResponse(from request: APIRequest) async throws -> APIResponse {
        AppLogger.warning("Sending request for model: \(String(describing: request.model))")
        
        guard var urlRequest = makeRequest(path: .chat, method: .POST) else {
            throw URLError(.badURL)
        }
        
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
        if let rawResponseString = String(data: data, encoding: .utf8) {
            AppLogger.debug("\(rawResponseString)")
        }
        
        do {
            let response = try JSONDecoder().decode(APIResponse.self, from: data)
            return APIResponse(
                text: response.text,
                usage: .init(promptTokens: response.usage.promptTokens, completionTokens: response.usage.completionTokens)
            )
        } catch {
            // Print raw JSON data when decoding fails
            if let rawResponseString = String(data: data, encoding: .utf8) {
                AppLogger.fault("Failed to decode response. Raw JSON:\n \(rawResponseString)")
            }
            
            // Try to decode as error response
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw RuntimeError(errorResponse.error.details)
            }
            
            throw RuntimeError("Failed to decode response: \(error.localizedDescription)")
        }
    }
    
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
                        // Collect the error response data
                        var errorData = Data()
                        for try await byte in result {
                            errorData.append(byte)
                        }
                        
                        // Log the raw error response
                        if let rawErrorString = String(data: errorData, encoding: .utf8) {
                            AppLogger.fault("Server error response: \(rawErrorString)")
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
                        
                        AppLogger.debug("\(line)")
                        
                        if let data = line.data(using: .utf8) {
                            do {
                                let response = try JSONDecoder().decode(ResponseType.self, from: data)
                                
                                switch response {
                                case .text(let content):
                                    continuation.yield(.text(content: content))
                                    
                                case .toolCall(let tool):
                                    continuation.yield(.toolCall(call: tool))
                                    
                                case .toolResult(let result):
                                    continuation.yield(.toolResult(result: result))
                                    
                                case .finish(let usage):
                                    continuation.yield(.finish(usage: usage))
                                    
                                case .error(let message):
                                    throw RuntimeError(message)
                                }
                            } catch {
                                AppLogger.error("Failed to decode stream response. Raw data:\n \(line)")
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
        
        if method == .POST {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
}

extension String {
    #if DEBUG
    static let apiHost = "http://localhost:3000/api"
    #else
    static let apiHost = "https://llm-api-server.vercel.app/api"
    #endif
}
