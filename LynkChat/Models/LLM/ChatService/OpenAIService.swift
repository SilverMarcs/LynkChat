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
//    
//    static func refreshModels(provider: String) async -> [GenericModel] {
//        return []
//    }
//
//    
//    static func testChatModel(provider: String, model: String, baseUrl: String?, apiKey: String?) async -> Bool {
//        return false
//    }
//}
//
//extension OpenAIService {
//    static func convertMessageToJSON(message: Message, dataFiles: [TypedData]) -> [String: Any] {
//           var content: [[String: Any]] = []
//           
//           // Add the main message content if not empty
//           if !message.content.isEmpty {
//               content.append([
//                   "type": "text",
//                   "text": message.content
//               ])
//           }
//           
//           // Process data files
//           let processedContent = FileHelper.processDataFiles(dataFiles, messageId: message.id.uuidString, role: message.role)
//           
//           for item in processedContent {
//               switch item {
//               case .text(let text):
//                   if !text.isEmpty {
//                       content.append([
//                           "type": "text",
//                           "text": text
//                       ])
//                   }
//               case .image(let mimeType, let data):
//                   // Only add images for user messages
//                   if message.role == .user {
//                       let base64String = data.base64EncodedString()
//                       content.append([
//                           "type": "image_url",
//                           "image_url": [
//                               "url": "data:\(mimeType);base64,\(base64String)",
//                               "detail": "low"  // or "high" if needed
//                           ]
//                       ])
//                   }
//               }
//           }
//           
//           return [
//               "role": message.role.rawValue,
//               "content": content
//           ]
//       }
//    
//    static func nonStreamingResponse(from request: APIRequest) async throws -> APIResponse {
//        print("doing OPENAI non stream")
//        
//        var body = createRequestBody(conversations: conversations, config: config)
//        
//        // Create a mutable copy of the JSON data
//        guard var bodyJson = try? JSONSerialization.jsonObject(with: body!) as? [String: Any] else {
//            throw NSError(domain: "InvalidRequestBody", code: -1, userInfo: nil)
//        }
//        
//        // Set stream to false for non-streaming response
//        bodyJson.removeValue(forKey: "stream")
//        bodyJson.removeValue(forKey: "stream_options")
//        
//        // Convert back to Data
//        body = try? JSONSerialization.data(withJSONObject: bodyJson)
//        
//        let urlStr = "\(config.provider.scheme.rawValue)://\(config.provider.host)/chat/completions"
//        let url = URL(string: urlStr) ?? URL(string: "https://api.openai.com/v1/chat/completions")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(request.customApiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = body
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
//            // Try to parse and print the error response as JSON
//            if let errorJson = try? JSONSerialization.jsonObject(with: data),
//               let prettyPrintedData = try? JSONSerialization.data(withJSONObject: errorJson, options: .prettyPrinted),
//               let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
//                print("\nServer Error Response:")
//                print(prettyPrintedString)
//            } else {
//                print("\nServer Error Response (raw):")
//                print(String(data: data, encoding: .utf8) ?? "Unable to decode error response")
//            }
//            
//            throw NSError(
//                domain: "APIRequestError",
//                code: (response as? HTTPURLResponse)?.statusCode ?? -1,
//                userInfo: ["message": "Request failed", "rawResponse": String(data: data, encoding: .utf8) ?? ""]
//            )
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
//            throw NSError(domain: "InvalidResponseFormat", code: -1, userInfo: nil)
//        }
//        
//        // Extract tokens based on config.provider.type
//        let promptTokens: Int
//        let completionTokens: Int
//        
//        if config.provider.type == .google {
//            // Use camel case keys for Google
//            guard let gPromptTokens = usage["promptTokens"] as? Int,
//                  let gCompletionTokens = usage["completionTokens"] as? Int else {
//                throw NSError(domain: "InvalidResponseFormat", code: -1, userInfo: ["message": "Tokens missing for Google provider"])
//            }
//            promptTokens = gPromptTokens
//            completionTokens = gCompletionTokens
//        } else {
//            // Use snake case keys for other providers (e.g., OpenAI)
//            guard let oPromptTokens = usage["prompt_tokens"] as? Int,
//                  let oCompletionTokens = usage["completion_tokens"] as? Int else {
//                throw NSError(domain: "InvalidResponseFormat", code: -1, userInfo: ["message": "Tokens missing for non-Google provider"])
//            }
//            promptTokens = oPromptTokens
//            completionTokens = oCompletionTokens
//        }
//        
//        // Pretty print the response for debugging
//        if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonResponse, options: .prettyPrinted),
//           let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
//            print("\nServer Response:")
//            print(prettyPrintedString)
//        }
//        
//        return NonStreamResponse(
//            content: content,
//            toolCalls: nil, // Explicitly returning nil as requested
//            inputTokens: promptTokens,
//            outputTokens: completionTokens
//        )
//    }
//       
//       static func createRequestBody(conversations: [Message], config: ChatConfig) -> Data? {
//           // Convert messages including their data files
//           var messages: [[String: Any]] = conversations.map { message in
//               convertMessageToJSON(message: message, dataFiles: message.dataFiles)
//           }
//           
//           // Add system prompt if present
//           if !config.systemPrompt.isEmpty {
//               messages.insert([
//                   "role": "system",
//                   "content": [["type": "text", "text": config.systemPrompt]]
//               ], at: 0)
//           }
//           
//           let body: [String: Any] = [
//               "model": config.model.code,
//               "messages": messages,
//               "temperature": config.temperature,
//               "max_tokens": config.maxTokens,
//               // TODO: omit for google provider but keep for openai
////               "frequency_penalty": config.frequencyPenalty,
////               "presence_penalty": config.presencePenalty,
//               "top_p": config.topP,
//               "stream": true,
//               "stream_options": ["include_usage": true],
////               "tools": []
//           ]
//           
//           return try? JSONSerialization.data(withJSONObject: body, options: [])
//       }
//    
//    static func streamResponse(from request: APIRequest) -> AsyncThrowingStream<StreamResponse, Error> {
//        print("doing OPENAI stream")
//        
//        guard let bodyData = createRequestBody(conversations: conversations, config: config) else {
//            return AsyncThrowingStream { $0.finish(throwing: NSError(domain: "InvalidRequestBody", code: -1, userInfo: nil)) }
//        }
//        
//        let urlStr = "\(config.provider.scheme.rawValue)://\(config.provider.host)/chat/completions"
//        let url = URL(string: urlStr) ?? URL(string: "https://api.openai.com/v1/chat/completions")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(config.provider.apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = bodyData
//        
//        return AsyncThrowingStream { continuation in
//            Task {
//                do {
//                    let (result, response) = try await URLSession.shared.bytes(for: request)
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
//                        // Try to parse and print the error response as JSON
//                        if let errorJson = try? JSONSerialization.jsonObject(with: errorData),
//                           let prettyPrintedData = try? JSONSerialization.data(withJSONObject: errorJson, options: .prettyPrinted),
//                           let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
//                            print("\nServer Error Response:")
//                            print(prettyPrintedString)
//                        } else {
//                            // If not JSON, print as string
//                            print("\nServer Error Response (raw):")
//                            print(String(data: errorData, encoding: .utf8) ?? "Unable to decode error response")
//                        }
//                        
//                        throw NSError(
//                            domain: "APIRequestError",
//                            code: (response as? HTTPURLResponse)?.statusCode ?? -1,
//                            userInfo: ["message": "Request failed", "rawResponse": String(data: errorData, encoding: .utf8) ?? ""]
//                        )
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
//                                if let delta = choices.first?["delta"] as? [String: Any],
//                                   let contentDelta = delta["content"] as? String {
//                                    currentContent += contentDelta
//                                    continuation.yield(.content(contentDelta))
//                                }
//                            } else if let usage = jsonObject["usage"] as? [String: Any] {
//                                // Parse token usage based on provider type
//                                let promptTokens: Int
//                                let completionTokens: Int
//                                
//                                if config.provider.type == .google {
//                                    // Use camel case for Google
//                                    guard let gPromptTokens = usage["promptTokens"] as? Int,
//                                          let gCompletionTokens = usage["completionTokens"] as? Int else {
//                                        print("\nMissing or invalid token keys for Google provider")
//                                        continue
//                                    }
//                                    promptTokens = gPromptTokens
//                                    completionTokens = gCompletionTokens
//                                } else {
//                                    // Use snake case for other providers (e.g., OpenAI)
//                                    guard let oPromptTokens = usage["prompt_tokens"] as? Int,
//                                          let oCompletionTokens = usage["completion_tokens"] as? Int else {
//                                        print("\nMissing or invalid token keys for non-Google provider")
//                                        continue
//                                    }
//                                    promptTokens = oPromptTokens
//                                    completionTokens = oCompletionTokens
//                                }
//                                
//                                let tokenUsage = TokenUsage(inputTokens: promptTokens, outputTokens: completionTokens)
//                                continuation.yield(.totalTokens(tokenUsage))
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
//}
