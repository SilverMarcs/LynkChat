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
    
    @AppStorage("quickSystemPrompt") var quickSystemPrompt: String = String.systemPrompt
    @AppStorage("systemPrompt") var systemPrompt: String = "You are a helpful assistant."
}
