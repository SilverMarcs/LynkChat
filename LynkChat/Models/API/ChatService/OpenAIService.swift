////
////  OpenAIService.swift
////  LynkChat
////
////  Created by Zabir Raihan on 30/07/2024.
////
//
//import Foundation
//
//struct OpenAIService: AIService {
//    static func refreshModels(provider: APIProvider) async -> [GenericModel] {
//        // Construct the URL
//        let urlString = "\(provider.scheme.rawValue)://\(provider.baseUrl)/models"
//        guard let url = URL(string: urlString) else {
//            return []
//        }
//        
//        // Create the request
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(provider.apiKey)", forHTTPHeaderField: "Authorization")
//        
//        // Response structure
//        struct ModelsResponse: Codable {
//            let data: [APIModel]
//        }
//        
//        do {
//            // Perform the request
//            let (data, response) = try await URLSession.shared.data(for: request)
//            
//            // Check for successful status code
//            guard let httpResponse = response as? HTTPURLResponse,
//                  (200...299).contains(httpResponse.statusCode) else {
//                return []
//            }
//            
//            // Decode the response
//            let decodedResponse = try JSONDecoder().decode(ModelsResponse.self, from: data)
//            
//            // Transform APIModel to GenericModel
//            return decodedResponse.data.map { model in
//                let name = model.id
//                    .split(separator: "-")
//                    .map { $0.capitalized }
//                    .joined(separator: " ")
//                
//                return GenericModel(
//                    code: model.id,
//                    name: name,
//                    isSelected: false,
//                    isExisting: false
//                )
//            }
//            
//        } catch {
//            print("Error fetching models: \(error)")
//            return []
//        }
//    }
//}
//
//extension OpenAIService {
//    // New helper function
//    private static func parseTokenUsage(from usage: [String: Any], providerName: String) throws -> TokenUsage {
//        let promptTokens: Int
//        let completionTokens: Int
//        
//        if providerName == ProviderType.customGoogle.rawValue {
//            // Use camel case keys for Google
//            guard let gPromptTokens = usage["promptTokens"] as? Int,
//                  let gCompletionTokens = usage["completionTokens"] as? Int else {
//                throw RuntimeError("Tokens missing for Google provider")
//            }
//            promptTokens = gPromptTokens
//            completionTokens = gCompletionTokens
//        } else {
//            // Use snake case keys for other providers (e.g., OpenAI)
//            guard let oPromptTokens = usage["prompt_tokens"] as? Int,
//                  let oCompletionTokens = usage["completion_tokens"] as? Int else {
//                throw RuntimeError("Tokens missing for non-Google provider")
//            }
//            promptTokens = oPromptTokens
//            completionTokens = oCompletionTokens
//        }
//        
//        return TokenUsage(promptTokens: promptTokens, completionTokens: completionTokens)
//    }
//
//    static func nonStreamingResponse(from request: APIRequest) async throws -> APIResponse {
//        print("doing OPENAI non stream")
//        
//        var body = createRequestBody(from: request)
//        
//        // Create a mutable copy of the JSON data
//        guard var bodyJson = try? JSONSerialization.jsonObject(with: body!) as? [String: Any] else {
//            throw RuntimeError("Failed to create request body")
//        }
//        
//        // Set stream to false for non-streaming response
//        bodyJson.removeValue(forKey: "stream")
//        bodyJson.removeValue(forKey: "stream_options")
//        
//        // Convert back to Data
//        body = try? JSONSerialization.data(withJSONObject: bodyJson)
//        
//        let urlStr = "\(request.provider.scheme.rawValue)://\(request.provider.baseUrl)/chat/completions"
//        let url = URL(string: urlStr) ?? URL(string: "https://api.openai.com/v1/chat/completions")!
//        var apiRequest = URLRequest(url: url)
//        apiRequest.httpMethod = "POST"
//        apiRequest.setValue("Bearer \(request.provider.apiKey)", forHTTPHeaderField: "Authorization")
//        apiRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        apiRequest.httpBody = body
//        
//        let (data, response) = try await URLSession.shared.data(for: apiRequest)
//        
//        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
//            let errorMessage = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
//            let error = (errorMessage?["error"] as? [String: Any])?["message"] as? String
//            throw RuntimeError(error ?? "Request failed with status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
//        }
//        
//        // Print the raw response
//        print("\nServer Response:")
//        print(String(data: data, encoding: .utf8) ?? "Unable to decode response")
//        
//        // Parse the response
//        guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//              let choices = jsonResponse["choices"] as? [[String: Any]],
//              let firstChoice = choices.first,
//              let message = firstChoice["message"] as? [String: Any],
//              let content = message["content"] as? String,
//              let usage = jsonResponse["usage"] as? [String: Any] else {
//            throw RuntimeError("Invalid response format from server")
//        }
//        
//        let tokenUsage = try parseTokenUsage(from: usage, providerName: request.provider.name)
//        
//        // Pretty print the response for debugging
//        if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonResponse, options: .prettyPrinted),
//           let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
//            print("\nServer Response:")
//            print(prettyPrintedString)
//        }
//        
//        return APIResponse(
//            text: content,
//            usage: tokenUsage
//        )
//    }
//    
//    // TODO: try async throws
//    static func streamResponse(from request: APIRequest) -> AsyncThrowingStream<StreamResponse, Error> {
//        print("doing OPENAI stream")
//        
//        guard let bodyData = createRequestBody(from: request) else {
//            return AsyncThrowingStream { $0.finish(throwing: RuntimeError("Failed to create request body")) }
//        }
//        
//        let urlStr = "\(request.provider.scheme.rawValue)://\(request.provider.baseUrl)/chat/completions"
//        let url = URL(string: urlStr) ?? URL(string: "https://api.openai.com/v1/chat/completions")!
//        var apiRequest = URLRequest(url: url)
//        apiRequest.httpMethod = "POST"
//        apiRequest.setValue("Bearer \(request.provider.apiKey)", forHTTPHeaderField: "Authorization")
//        apiRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        apiRequest.httpBody = bodyData
//        
//        return AsyncThrowingStream { continuation in
//            Task {
//                do {
//                    let (result, response) = try await URLSession.shared.bytes(for: apiRequest)
//                    
//                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
//                        // Collect error response as Data
//                        var errorData = Data()
//                        
//                        // Read all bytes from the result
//                        for try await byte in result {
//                            errorData.append(byte)
//                        }
//                        
//                        let errorMessage = try? JSONSerialization.jsonObject(with: errorData) as? [String: Any]
//                        let error = (errorMessage?["error"] as? [String: Any])?["message"] as? String
//                        throw RuntimeError(error ?? "Stream request failed with status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
//                    }
//                    
//                    // Existing streaming logic
//                    var currentContent = ""
//                    
//                    for try await line in result.lines {
//                        try Task.checkCancellation()
//                        
//                        guard line.hasPrefix("data: ") else {
//                            continue
//                        }
//                        
//                        let jsonString = String(line.dropFirst(6))
//                        
//                        // Try to parse the response
//                        if let jsonData = jsonString.data(using: .utf8),
//                           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
//                            // Pretty print the response chunk
//                            if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
//                               let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
//                                print("\nServer Response Chunk:")
//                                print(prettyPrintedString)
//                            }
//                            
//                            if let choices = jsonObject["choices"] as? [[String: Any]], !choices.isEmpty {
//                                if let delta = choices.first?["delta"] as? [String: Any] {
//                                    if let contentDelta = delta["content"] as? String {
//                                        currentContent += contentDelta
//                                        continuation.yield(StreamResponse.text(contentDelta))
//                                    }
//                                    // Check if this is the final chunk with usage information
//                                    let isFinished = choices.first?["finish_reason"] as? String == "stop" ||
//                                                    choices.first?["finishReason"] as? String == "stop"
//                                    if isFinished, let usage = jsonObject["usage"] as? [String: Any] {
//                                        do {
//                                            let tokenUsage = try parseTokenUsage(from: usage, providerName: request.provider.name)
//                                            continuation.yield(StreamResponse.usage(tokenUsage))
//                                        } catch {
//                                            print("\nError parsing token usage: \(error)")
//                                        }
//                                    }
//                                }
//                            } else if let usage = jsonObject["usage"] as? [String: Any] {
//                                // Fallback check for usage information
//                                do {
//                                    let tokenUsage = try parseTokenUsage(from: usage, providerName: request.provider.name)
//                                    continuation.yield(StreamResponse.usage(tokenUsage))
//                                } catch {
//                                    print("\nError parsing token usage: \(error)")
//                                }
//                            }
//                        } else {
//                            print("\nFailed to parse response chunk:")
//                            print(jsonString)
//                        }
//                    }
//                    
//                    continuation.finish()
//                } catch {
//                    continuation.finish(throwing: error)
//                }
//            }
//        }
//    }
//    
//    static func createRequestBody(from request: APIRequest) -> Data? {
//           // Convert messages including their data files
//        var messages: [[String: Any]] = request.messages.map { message in
//           convertMessageToJSON(message: message)
//       }
//       
//       // Add system prompt if present
//        if let system = request.system, !system.isEmpty {
//            messages.insert([
//                "role": "system",
//                "content": [["type": "text", "text": system]]
//            ], at: 0)
//        }
//           
//       let body: [String: Any] = [
//            "model": request.model,
//            "messages": messages,
//            "stream": request.stream,
//            "stream_options": ["include_usage": true],
//       ]
//           
//           return try? JSONSerialization.data(withJSONObject: body, options: [])
//       }
//    
//    static func convertMessageToJSON(message: APIMessage) -> [String: Any] {
//        var contents: [[String: Any]] = []
//        
//        for content in message.content {
//            switch content {
//            case .text(let text):
//                if !text.isEmpty {
//                    contents.append([
//                        "type": "text",
//                        "text": text
//                    ])
//                }
//            case .image(let mimeType, let data):
//                // Only add images for user messages
//                if message.role == .user {
//                    let base64String = data.base64EncodedString()
//                    contents.append([
//                        "type": "image_url",
//                        "image_url": [
//                            "url": "data:\(mimeType);base64,\(base64String)",
//                            "detail": "auto"
//                        ]
//                    ])
//                }
//            }
//        }
//        
//        return [
//            "role": message.role.rawValue,
//            "content": contents
//        ]
//    }
//}
