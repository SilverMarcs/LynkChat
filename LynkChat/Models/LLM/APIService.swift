//
//  APIService.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/12/2024.
//

import Foundation

struct APIService {
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
    
    static func nonStreamingResponse(from conversations: [Message], config: ChatConfig) async throws -> NonStreamResponse {
        guard var request = makeRequest(path: "/chat", method: "POST") else {
            throw URLError(.badURL)
        }
        
        let requestBody = makeChatRequestBody(
            provider: config.provider.type.rawValue,
            model: config.model.code,
            messages: conversations,
            stream: config.stream,
            baseUrl: config.provider.host,
            key: config.provider.apiKey
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let response = try JSONDecoder().decode(APIResponse.self, from: data)
            return NonStreamResponse(
                content: response.text,
                inputTokens: response.usage.promptTokens,
                outputTokens: response.usage.completionTokens
            )
        } catch {
            // Try to decode as error response
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw RuntimeError(errorResponse.error.details)
            }
            
            // If error response decoding fails, print raw response and throw original error
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw API Response:", rawResponse)
            }
            throw error
        }
    }
    
    static func streamResponse(from conversations: [Message], config: ChatConfig) -> AsyncThrowingStream<StreamResponse, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    guard var request = makeRequest(path: "/chat", method: "POST") else {
                        throw URLError(.badURL)
                    }
                    
                    let requestBody = makeChatRequestBody(
                        provider: config.provider.type.rawValue,
                        model: config.model.code,
                        messages: conversations,
                        stream: true,
                        baseUrl: config.provider.host,
                        key: config.provider.apiKey
                    )
                    
                    request.httpBody = try JSONEncoder().encode(requestBody)
                    
                    let (result, response) = try await URLSession.shared.bytes(for: request)
                    
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
                                    continuation.yield(.content(content))
                                }
                                
                            case "finish":
                                if let usage = response.usage {
                                    let tokenUsage = TokenUsage(
                                        inputTokens: usage.promptTokens,
                                        outputTokens: usage.completionTokens
                                    )
                                    continuation.yield(.totalTokens(tokenUsage))
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
}

extension APIService {
    // Helper for creating base URLRequest with common headers
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
    
    private static func convertMessagesToAPIFormat(_ messages: [Message]) -> [APIMessage] {
       return messages.map { message in
           var contentItems: [APIMessageContent] = []
           
           // Always add text content as first item if it exists
           if !message.content.isEmpty {
               contentItems.append(APIMessageContent(
                   type: "text",
                   text: message.content,
                   image: nil
               ))
           }
           
           // Add any data files
           let processedItems = FileHelper.processDataFiles2(message.dataFiles)
           for item in processedItems {
               switch item {
               case .text(let text):
                   contentItems.append(APIMessageContent(
                       type: "text",
                       text: text,
                       image: nil
                   ))
               case .image(_, let data):
                   contentItems.append(APIMessageContent(
                       type: "image",
                       text: nil,
                       image: data.base64EncodedString()
                   ))
               }
           }
           
           return APIMessage(
               role: message.role.rawValue,
               content: contentItems
           )
       }
   }
       
    private static func makeChatRequestBody(
        provider: String,
        model: String,
        messages: [Message],
        stream: Bool,
        baseUrl: String,
        key: String
    ) -> APIRequest {
        return APIRequest(
            provider: provider.lowercased(),
            model: model,
            messages: convertMessagesToAPIFormat(messages),
            stream: stream,
            customBaseUrl: provider == "custom" ? baseUrl : nil,
            customApiKey: AppConfig.shared.sendOwnKey ? key : nil
        )
   }
}

struct APIModel: Codable {
    let id: String
    let name: String
}

private struct APIResponse: Decodable {
    let text: String
    let finishReason: String
    let usage: Usage
    
    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
    }
}

struct APIMessageContent: Encodable {
    let type: String
    let text: String?
    let image: String?
}

struct APIMessage: Encodable {
    let role: String
    let content: [APIMessageContent]
}

private struct APIRequest: Encodable {
    let provider: String
    let model: String
    let messages: [APIMessage]
    let stream: Bool
    let customBaseUrl: String?
    let customApiKey: String? // TODO: encrypt this
}

private struct UsageResponse: Decodable {
    let finishReason: String
    let usage: Usage
    
    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
    }
}

private struct StreamChunk: Decodable {
    let type: String
    let content: String?
    let finishReason: String?
    let usage: Usage?
    
    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
    }
}

private struct APIErrorResponse: Decodable {
    let error: ErrorDetails
    
    struct ErrorDetails: Decodable {
        let message: String
        let type: String
        let details: String
    }
}
