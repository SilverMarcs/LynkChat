//
//  BedrockService.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/12/2024.
//

import Foundation
import AWSBedrock
import AWSBedrockRuntime
import SmithyIdentity
import Smithy

struct MyCredentialProvider: AWSCredentialIdentityResolver {
    func getIdentity(identityProperties: Smithy.Attributes?) async throws -> AWSCredentialIdentity {
         return AWSCredentialIdentity(accessKey: ChatConfigDefaults.shared.bedrockAccessKey, secret: ChatConfigDefaults.shared.bedrockSecretKey)
    }
}

struct BedrockService: AIService {
    typealias ConvertedType = ClaudeMessage
    
    static func convert(conversation: Message) -> ClaudeMessage {
        var contents = [ClaudeMessage.Content]()
        
        // Process data files (images and other content)
        let contentItems = FileHelper.processDataFiles(conversation.dataFiles, messageId: conversation.id.uuidString, role: conversation.role)
        for item in contentItems {
            switch item {
            case .text(let text):
                contents.append(ClaudeMessage.Content(type: "text", text: text))
            case .image(let mimeType, let imageData):
                // Convert image data to base64
                let base64String = imageData.base64EncodedString()
                
                // Create image content with source
                contents.append(ClaudeMessage.Content(
                    type: "image",
                    text: nil,
                    source: base64String
                ))
            }
        }
        
        // Add text content if present
        if !conversation.content.isEmpty {
            contents.append(ClaudeMessage.Content(type: "text", text: conversation.content))
        }
        
        return ClaudeMessage(
            role: conversation.role.rawValue,
            content: contents
        )
    }
    
    static func getService() -> BedrockRuntimeClient {
        let region = "us-east-1"
        let configer = MyCredentialProvider()
        
        let runtimeConfig = try! BedrockRuntimeClient.BedrockRuntimeClientConfiguration(
            awsCredentialIdentityResolver: configer,
            region: region,
            signingRegion: region
        )
        return BedrockRuntimeClient(config: runtimeConfig)
    }

    static func refreshModels(provider: Provider) async -> [GenericModel] {
        do {
            let request = ListFoundationModelsInput()
            let bedrockClient = try await BedrockClient()
            let response = try await bedrockClient.listFoundationModels(input: request)
            
            guard let modelSummaries = response.modelSummaries else {
                return []
            }
            
            return modelSummaries
                .filter { summary in
                    let modelId = summary.modelId ?? ""
                    return modelId.lowercased().contains("claude")
                }
                .map { summary in
                    let modelId = summary.modelId ?? ""
                    let modelName = summary.modelName ?? modelId
                    return GenericModel(
                        code: "us.\(modelId)",
                        name: modelName
                    )
                }
        } catch {
            print("Error refreshing models: \(error)")
            return []
        }
    }

    static func streamResponse(from conversations: [Message], config: ChatConfig) -> AsyncThrowingStream<StreamResponse, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let request = try createStreamRequest(messages: conversations, config: config)
                    let client = Self.getService()
                    
                    if let body = request.body, let requestString = String(data: body, encoding: .utf8) {
                        print("Request Body: \(requestString)")
                    }
                    
                    let response = try await client.invokeModelWithResponseStream(input: request)
                    print("Response received, starting stream processing")
                    
                    guard let stream = response.body else {
                        print("No stream body received")
                        continuation.finish()
                        return
                    }
                    
                    for try await chunk in stream {
                        if case .chunk(let payloadPart) = chunk,
                           let bytes = payloadPart.bytes,
                           let json = try? JSONSerialization.jsonObject(with: bytes) as? [String: Any] {
                            print("Received chunk:\n\(json)")
                            
                            if let type = json["type"] as? String {
                                switch type {
                                case "content_block_delta":
                                    if let delta = json["delta"] as? [String: Any],
                                       let textDelta = delta["text"] as? String {
                                        continuation.yield(.content(textDelta))
                                    }
                                    
                                case "message_stop":
                                    if let metrics = json["amazon-bedrock-invocationMetrics"] as? [String: Any],
                                       let input = metrics["inputTokenCount"] as? Int,
                                       let output = metrics["outputTokenCount"] as? Int {
                                        // Yield token usage before finishing
                                        continuation.yield(.totalTokens(TokenUsage(
                                            inputTokens: input,
                                            outputTokens: output
                                        )))
                                    }
                                default:
                                    print("Unknown message type: \(type)")
                                    break
                                }
                            }
                        }
                    }
                    
                    print("Stream completed")
                    continuation.finish()
                } catch {
                    print("Error in stream: \(error)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    static func nonStreamingResponse(from conversations: [Message], config: ChatConfig) async throws -> NonStreamResponse {
        do {
            let request = try createNonStreamRequest(messages: conversations, config: config)
            let client = Self.getService()
            
            // Debug logging
            if let body = request.body, let requestString = String(data: body, encoding: .utf8) {
                print("Request Body: \(requestString)")
            }
            
            let response = try await client.invokeModel(input: request)
            
            guard let responseData = response.body,
                  let responseString = String(data: responseData, encoding: .utf8) else {
                throw RuntimeError("No response body received")
            }
            
            print("Response received: \(responseString)")
            
            // Decode the response
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let claudeResponse = try decoder.decode(ClaudeMessageResponse.self, from: responseData)
            
            // Extract the text content from the response
            let content = claudeResponse.content
                .filter { $0.type == "text" }
                .compactMap { $0.text }
                .joined()
            
            return NonStreamResponse(
                content: content,
                toolCalls: [], // Claude doesn't support tool calls in this implementation
                inputTokens: claudeResponse.usage.inputTokens,
                outputTokens: claudeResponse.usage.outputTokens
            )
        } catch {
            print("Error in non-streaming response: \(error)")
            throw error
        }
    }
    
    private static func createStreamRequest(messages: [Message], config: ChatConfig) throws -> InvokeModelWithResponseStreamInput {
        // Use the convert function to transform messages
        let claudeMessages = messages.map { message in
            convert(conversation: message) // Note: You might want to handle the error case properly
        }
        
        let requestBody = ClaudeMessageRequest(
            anthropicVersion: "bedrock-2023-05-31",
            maxTokens: config.maxTokens ?? 4096,
            system: config.systemPrompt,
            messages: claudeMessages,
            temperature: 0.7,
            topP: config.topP
        )
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try encoder.encode(requestBody)
        
        return InvokeModelWithResponseStreamInput(
            body: jsonData,
            contentType: "application/json",
            modelId: config.model.code
        )
    }
    
    private static func createNonStreamRequest(messages: [Message], config: ChatConfig) throws -> InvokeModelInput {
        // Use the convert function to transform messages
        let claudeMessages = messages.map { message in
            convert(conversation: message) // Note: You might want to handle the error case properly
        }
        
        let requestBody = ClaudeMessageRequest(
            anthropicVersion: "bedrock-2023-05-31",
            maxTokens: config.maxTokens ?? 4096,
            system: config.systemPrompt,
            messages: claudeMessages,
            temperature: 0.7,
            topP: config.topP
        )
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try encoder.encode(requestBody)
        
        return InvokeModelInput(
            body: jsonData,
            contentType: "application/json",
            modelId: config.model.code
        )
    }
    
    static func testModel(provider: Provider, model: AIModel) async -> Bool {
        return false // TODO: Implement this
    }
}

struct ClaudeMessage: Codable {
    let role: String
    let content: [Content]
    
    struct Content: Codable {
        let type: String
        let text: String?
        let source: ImageSource?
        
        // Custom initializer for text content
        init(type: String, text: String? = nil) {
            self.type = type
            self.text = text
            self.source = nil
        }
        
        // Custom initializer for image content
        init(type: String, text: String? = nil, source: String) {
            self.type = type
            self.text = text
            self.source = ImageSource(
                type: "base64",
                mediaType: "image/jpeg", // Adjust based on your image type
                data: source
            )
        }
        
        struct ImageSource: Codable {
            let type: String
            let mediaType: String
            let data: String
            
            enum CodingKeys: String, CodingKey {
                case type
                case mediaType = "media_type"
                case data
            }
        }
    }
}

struct ClaudeMessageRequest: Codable {
    let anthropicVersion: String
    let maxTokens: Int
    let system: String?
    let messages: [ClaudeMessage]
    let temperature: Double?
    let topP: Double?
}

struct ClaudeMessageResponse: Codable {
    let id: String
    let model: String
    let type: String
    let role: String
    let content: [Content]
    let stopReason: String
    let stopSequence: String?
    let usage: Usage
    
    struct Content: Codable {
        let type: String
        let text: String?
    }
    
    struct Usage: Codable {
        let inputTokens: Int
        let outputTokens: Int
    }
}
