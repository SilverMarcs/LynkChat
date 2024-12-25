//
//  ToolProtocol.swift
//  LynkChat
//
//  Created by Zabir Raihan on 07/10/2024.
//

import Foundation
import OpenAI

protocol ToolProtocol {
    static var openai: ChatQuery.ChatCompletionToolParam { get }
    static var jsonSchemaString: String { get }
    static var toolName: String { get }
    static var displayName: String { get }
    static var icon: String { get }
    static func process(arguments: String) async throws -> ToolData
}
