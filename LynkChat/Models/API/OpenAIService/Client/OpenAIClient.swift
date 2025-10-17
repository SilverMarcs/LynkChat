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
    
    init(apiKey: String, baseURL: String) {
        self.apiKey = apiKey
        self.baseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
    }
    
    func streamChatCompletion(
        messages: [ChatRequestMessage],
        model: String,
        temperature: Double? = 0.3,
        maxTokens: Int? = nil,
        tools: [ChatCompletionRequest.Tool]? = nil,
        thinkingBudget: ThinkingBudget = .none
    ) -> AsyncThrowingStream<ChatStreamResponse, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let reasoning: ChatCompletionRequest.Reasoning? = thinkingBudget != .none ? ChatCompletionRequest.Reasoning(effort: thinkingBudget) : nil
                    
                    let request = ChatCompletionRequest(
                        model: model,
                        messages: messages,
                        stream: true,
                        temperature: temperature,
                        max_tokens: maxTokens,
                        tools: tools,
                        reasoning: reasoning
                    )
                    
                    let url = URL(string: "\(baseURL)/chat/completions")!
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    urlRequest.httpBody = try JSONEncoder().encode(request)
                    
                    let (asyncBytes, response) = try await URLSession.shared.bytes(for: urlRequest)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        AppLogger.critical("OpenAI client error: Invalid response from server")
                        throw OpenAIError.invalidResponse
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        // Try to read error response body
                        var errorData = Data()
                        for try await byte in asyncBytes {
                            errorData.append(byte)
                        }
                        
                        let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unable to read error data"
                        
                        // Log the full request body for debugging
                        if let requestBody = urlRequest.httpBody,
                           let requestBodyString = String(data: requestBody, encoding: .utf8) {
                            AppLogger.critical("OpenAI client request body for model \(model): \(requestBodyString)")
                        }
                        
                        AppLogger.critical("OpenAI client HTTP error \(httpResponse.statusCode) for model \(model): \(errorMessage)")
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
                                        } catch let decodingError {
                                            AppLogger.critical("OpenAI client decoding error for model \(model): \(decodingError.localizedDescription)")
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
                } catch let error as OpenAIError {
                    // Re-throw OpenAI errors (already logged above)
                    continuation.finish(throwing: error)
                } catch {
                    AppLogger.critical("OpenAI client unexpected error for model \(model): \(error.localizedDescription)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func sendSingleMessage(messages: [ChatRequestMessage], model: String) async throws -> String {
        var fullResponse = ""
        
        for try await chunk in streamChatCompletion(messages: messages, model: model) {
            if let content = chunk.choices.first?.delta.content {
                fullResponse.append(content)
            }
        }
        
        return fullResponse
    }
    
    // Helper to convert image data to base64 data URL
    static func imageDataURL(from data: Data, mimeType: String = "image/jpeg") -> String {
        let base64 = data.base64EncodedString()
        return "data:\(mimeType);base64,\(base64)"
    }
}
