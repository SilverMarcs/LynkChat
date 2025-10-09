//
//  ToolCall.swift
//  SwiftAI
//
//  Created on 05/10/2025.
//

import Foundation
import SwiftUI

// MARK: - Tool Definition

enum Tool: String, Codable, CaseIterable {
    case generateImage
    case editImage
    
    var displayName: String {
        switch self {
        case .generateImage: "Generate Image"
        case .editImage: "Edit Image"
        }
    }
    
    var title: String {
        displayName
    }
    
    var symbol: String {
        switch self {
        case .generateImage: "photo.badge.plus"
        case .editImage: "pencil.and.outline"
        }
    }
    
    var iconName: String {
        symbol
    }
    
    var color: Color {
        switch self {
        case .generateImage, .editImage: .mint
        }
    }
    
    var description: String {
        switch self {
        case .generateImage:
            "Generates an image from a text prompt using AI."
        case .editImage:
            "Edits an existing image or image based on a text prompt. If the user asks to edit multiple images, you must inform that you can only edit single image but you may take inspiration from multiple images and edit into one singular image"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .generateImage:
            [
                "type": "object",
                "properties": [
                    "prompt": ["type": "string", "description": "Description of the image to generate"]
                ],
                "required": ["prompt"]
            ]
        case .editImage:
            [
                "type": "object",
                "properties": [
                    "prompt": ["type": "string", "description": "Description of how to edit the image"]
                ],
                "required": ["prompt"]
            ]
        }
    }
    
    var requiresAIFollowup: Bool {
        switch self {
        case .generateImage, .editImage:
            return false
        }
    }
    
    func execute(arguments: String, messages: [Message]) async -> ToolCall.Result? {
//        switch self {
//        case .generateImage:
//            return await executeGenerateImage(arguments: arguments)
//        case .editImage:
//            return await executeEditImage(arguments: arguments, messages: messages)
//        }
        return .init(text: "daas", data: [])
    }
    
    // MARK: - API Conversion
    
    func toAPITool() -> ChatCompletionRequest.Tool {
        return ChatCompletionRequest.Tool(
            type: "function",
            function: ChatCompletionRequest.Tool.Function(
                name: rawValue,
                description: description,
                parameters: parameters.mapValues { AnyCodable($0) }
            )
        )
    }
    
    static var allAPITools: [ChatCompletionRequest.Tool] {
        allCases.map { $0.toAPITool() }
    }
}
