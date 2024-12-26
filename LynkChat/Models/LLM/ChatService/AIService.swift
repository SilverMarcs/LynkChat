//
//  AIService.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/07/2024.
//

import SwiftUI

protocol AIService {    
    static func streamResponse(from request: APIRequest) -> AsyncThrowingStream<StreamResponse, Error>
    static func nonStreamingResponse(from request: APIRequest) async throws -> NonStreamResponse
    static func testChatModel(provider: String, model: String, baseUrl: String?, apiKey: String?) async -> Bool
    static func refreshModels(provider: String) async -> [GenericModel]
}
