//
//  ChatConfigDefaults.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

class ChatConfigDefaults: ObservableObject {
    static let shared = ChatConfigDefaults()
    private init() {}
    
    @AppStorage("defaultModel") var defaultModel: ChatModel = .small_model
    
    @AppStorage("temperature") var temperature: Temperature = .balanced
    @AppStorage("maxTokens") var maxTokens: MaxTokens = .t4096
    
    @AppStorage("quickSystemPrompt") var quickSystemPrompt: String = "Keep your responses fairly concise."
    #if os(macOS)
    @AppStorage("systemPrompt") var systemPrompt: String = String.systemPrompt
    #else
    @AppStorage("systemPrompt") var systemPrompt: String = String.systemPrompt + "\n Be concise with your responses"
    #endif
}

extension String {
    static let systemPrompt = """
    You are a helpful assistant.
    """
    
    static let toolExtras = """
    The assistant has access to tools like Web Search for finding latest information beyond your knowledge cutoff, Image Generation to generate images as per user request. If the user made a request that requires usage of such tools but did not pass such tools to you, you may notify the user to enable them in settings. But unless you are most certain that user's messages do not require using tools, make no mention of these tools.
    """
}
