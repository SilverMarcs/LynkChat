//
//  APIService.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/12/2024.
//

import Foundation

extension String {
    static let apiHost = "http://localhost:3000/api"
}

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
            stream: config.stream
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(APIResponse.self, from: data)
        
        return NonStreamResponse(
            content: response.text,
            toolCalls: nil,
            inputTokens: response.usage.promptTokens,
            outputTokens: response.usage.completionTokens
        )
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
                        stream: true
                    )
                    
                    request.httpBody = try JSONEncoder().encode(requestBody)
                    
                    let (result, _) = try await URLSession.shared.bytes(for: request)
                        
                    
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
        guard let url = URL(string: "\(String.apiHost)\(path)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("12345678", forHTTPHeaderField: "x-api-key")
        
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
        stream: Bool
    ) -> APIRequest {
        return APIRequest(
            provider: provider.lowercased(),
            model: model,
            messages: convertMessagesToAPIFormat(messages),
            stream: stream
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
