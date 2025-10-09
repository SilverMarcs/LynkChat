//
//  OpenAIClient.swift
//  SwiftAI
//
//  Created on 05/10/2025.
//

import Foundation

// MARK: - OpenAI Client

class OpenAIClient {
    let apiKey: String
    let baseURL: String
    let model: String
    
    init(apiKey: String, baseURL: String = "https://api.openai.com/v1", model: String = "gpt-5-nano") {
        self.apiKey = apiKey
        self.baseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        self.model = model
    }
    
    func streamChatCompletion(
        messages: [ChatRequestMessage],
        temperature: Double? = 0.3,
        maxTokens: Int? = nil,
        tools: [ChatCompletionRequest.Tool]? = nil
    ) -> AsyncThrowingStream<ChatStreamResponse, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let request = ChatCompletionRequest(
                        model: model,
                        messages: messages,
                        stream: true,
                        temperature: temperature,
                        max_tokens: maxTokens,
                        tools: tools
                    )
                    
                    let url = URL(string: "\(baseURL)/chat/completions")!
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    urlRequest.httpBody = try JSONEncoder().encode(request)
                    
                    let (asyncBytes, response) = try await URLSession.shared.bytes(for: urlRequest)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw OpenAIError.invalidResponse
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        throw OpenAIError.httpError(statusCode: httpResponse.statusCode)
                    }
                    
                    var buffer = ""
                    
                    for try await byte in asyncBytes {
                        let char = Character(UnicodeScalar(byte))
                        buffer.append(char)
                        
                        // SSE format: data: {...}\n\n
                        if buffer.hasSuffix("\n\n") || buffer.hasSuffix("\r\n\r\n") {
                            let lines = buffer.components(separatedBy: .newlines)
                            
                            for line in lines {
                                let trimmed = line.trimmingCharacters(in: .whitespaces)
                                
                                if trimmed.hasPrefix("data: ") {
                                    let data = trimmed.dropFirst(6)
                                    
                                    if data == "[DONE]" {
                                        continuation.finish()
                                        return
                                    }
                                    
                                    if let jsonData = data.data(using: .utf8) {
                                        do {
                                            let streamResponse = try JSONDecoder().decode(ChatStreamResponse.self, from: jsonData)
                                            continuation.yield(streamResponse)
                                        } catch {
                                            // Skip malformed chunks
                                            continue
                                        }
                                    }
                                }
                            }
                            
                            buffer = ""
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // Helper to convert image data to base64 data URL
    static func imageDataURL(from data: Data, mimeType: String = "image/jpeg") -> String {
        let base64 = data.base64EncodedString()
        return "data:\(mimeType);base64,\(base64)"
    }
}
