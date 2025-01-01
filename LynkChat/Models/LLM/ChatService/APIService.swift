//
//  APIService.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/12/2024.
//

import Foundation

enum APIService {
    static func nonStreamingResponse(from request: APIRequest) async throws -> APIResponse {
        AppLogger.warning("Sending request for model: \(String(describing: request.model))")
        
        guard var urlRequest = makeRequest(path: .chat, method: .POST) else {
            throw URLError(.badURL)
        }
        
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // First check if it's an error response
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw RuntimeError(errorResponse.error)
        }
        
        if let rawResponseString = String(data: data, encoding: .utf8) {
            AppLogger.debug("\(rawResponseString)")
        }
        
        do {
            return try JSONDecoder().decode(APIResponse.self, from: data)
        } catch {
            AppLogger.fault("Failed to decode response: \(error.localizedDescription)")
            throw error
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
                        var errorData = Data()
                        for try await byte in result {
                            errorData.append(byte)
                        }
                        
                        let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: errorData)
                        throw RuntimeError(errorResponse.error)
                    }
                    
                    for try await line in result.lines {
                        if line.isEmpty { continue }
                        
                        AppLogger.debug("\(line)")
                        
                        if let data = line.data(using: .utf8) {
                            let response = try JSONDecoder().decode(ResponseType.self, from: data)
                            
                            switch response {
                            case .text(let textResponse):
                                continuation.yield(.text(textResponse))
                            case .toolCall(let toolCallResponse):
                                continuation.yield(.toolCall(toolCallResponse))
                            case .toolResult(let toolResultResponse):
                                continuation.yield(.toolResult(toolResultResponse))
                            case .finish(let finishResponse):
                                continuation.yield(.finish(finishResponse))
                            case .error(let errorResponse):
                                throw RuntimeError(errorResponse.content)
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
    
    static var apiHost: String {
        if AppConfig.shared.useLocalhost {
            "http://localhost:3000/api"
        } else {
            "https://llm-api-server.vercel.app/api"
        }
    }
    #else
    static let apiHost = "https://llm-api-server.vercel.app/api"
    #endif
}
