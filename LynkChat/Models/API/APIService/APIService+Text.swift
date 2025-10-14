////
////  APIService.swift
////  LynkChat
////
////  Created by Zabir Raihan on 25/12/2024.
////
//
//import Foundation
//
//extension APIService {
//    static func streamResponse(from request: APIRequest) -> AsyncThrowingStream<ResponseType, Error> {
//        AppLogger.warning("Streaming response for model: \(String(describing: request.model))")
//        
//        return AsyncThrowingStream { continuation in
//            Task {
//                do {
//                    guard var urlRequest = makeRequest(path: .chat, method: .POST) else {
//                        throw URLError(.badURL)
//                    }
//                    
//                    urlRequest.httpBody = try JSONEncoder().encode(request)
//                    
//                    let (result, response) = try await URLSession.shared.bytes(for: urlRequest)
//                    
//                    // Check if we received an error response
//                    if let httpResponse = response as? HTTPURLResponse,
//                       !(200...299).contains(httpResponse.statusCode) {
//                        var errorData = Data()
//                        for try await byte in result {
//                            errorData.append(byte)
//                        }
//                        
//                        try handleAPIResponse(data: errorData, response: response, context: "Server streaming")
//                    }
//                    
//                    for try await line in result.lines {
//                        if line.isEmpty { continue }
//                        
//                        AppLogger.debug("\(line)")
//                        
//                        if let data = line.data(using: .utf8) {
//                            do {
//                                let response = try JSONDecoder().decode(ResponseType.self, from: data)
//                                
//                                switch response {
//                                case .text(let textResponse):
//                                    continuation.yield(.text(textResponse))
//                                case .reasoning(let reasoningResponse):
//                                    continuation.yield(.reasoning(reasoningResponse))
//                                case .reasoningEnd(let reasoningEndResponse):
//                                    continuation.yield(.reasoningEnd(reasoningEndResponse))
//                                case .toolCall(let toolCallResponse):
//                                    continuation.yield(.toolCall(toolCallResponse))
//                                case .toolResult(let toolResultResponse):
//                                    continuation.yield(.toolResult(toolResultResponse))
//                                case .file(let fileResponse):
//                                    continuation.yield(.file(fileResponse))
//                                case .finish(let finishResponse):
//                                    continuation.yield(.finish(finishResponse))
//                                case .error(let errorResponse):
//                                    throw RuntimeError(errorResponse.content)
//                                }
//                            } catch {
//                                AppLogger.error("Decoding error: \(error.localizedDescription)")
//                                AppLogger.error("Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
//                                throw error
//                            }
//                        }
//                    }
//                    
//                    continuation.finish()
//                } catch {
//                    AppLogger.error("Stream error: \(error.localizedDescription)")
//                    continuation.finish(throwing: error)
//                }
//            }
//        }
//    }
//    
//    static func basicResponse(prompt: String) async throws -> String {
//        let request = TitleRequest(prompt: prompt)
//        let titleResponse: TitleResponse = try await performRequest(
//            path: .title,
//            method: .POST,
//            body: request,
//            responseType: TitleResponse.self,
//            context: "Title generation"
//        )
//        return titleResponse.title
//    }
//}
