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
    
    @AppStorage("temperature") var temperature: Double = 0.7
    @AppStorage("maxTokens") var maxTokens: MaxTokens = .t4096
    
    @AppStorage("quickSystemPrompt") var quickSystemPrompt: String = "Keep your responses fairly concise."
    #if os(macOS)
    @AppStorage("systemPrompt") var systemPrompt: String = String.systemPrompt
    #else
    @AppStorage("systemPrompt") var systemPrompt: String = String.systemPrompt + "\n\n + Be concise with your responses"
    #endif
}
