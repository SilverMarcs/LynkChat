//
//  ChatConfigDefaults.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

struct ChatConfigDefaults {
    @AppStorage("defaultModel") var defaultModel: ChatModel = .gemini_flash
    @AppStorage("temperature") var temperature: Temperature = .balanced
    @AppStorage("thinkingBudget") var thinkingBudget: ThinkingBudget = .none
    
    @AppStorage("quickDefaultModel") var quickDefaultModel: ChatModel = .gemini_flash
    @AppStorage("quickSystemPrompt") var quickSystemPrompt: String = "Keep your responses fairly concise."
    
    @AppStorage("systemPrompt") var systemPrompt: String = String.systemPrompt
}

extension String {
    #if os(macOS)
    static let systemPrompt = """
    You are a helpful assistant.
    """
    #else
    static let systemPrompt = """
    You are a helpful assistant.
    """ + "\n Be concise with your responses"
    #endif
}
