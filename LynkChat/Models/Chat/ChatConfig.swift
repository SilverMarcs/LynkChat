//
//  OldChatConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation
import SwiftData

struct ChatConfig: Identifiable, Codable {
    var id = UUID()
    var temperature: Double? = ChatConfigDefaults.shared.temperature
    var frequencyPenalty: Double? = ChatConfigDefaults.shared.frequencyPenalty
    var presencePenalty: Double? = ChatConfigDefaults.shared.presencePenalty
    var topP: Double? = ChatConfigDefaults.shared.topP
    var maxTokens: Int? = ChatConfigDefaults.shared.maxTokens
    var stream: Bool = ChatConfigDefaults.shared.stream
    var systemPrompt: String = ChatConfigDefaults.shared.systemPrompt
    var model: LynkModel = ModelConfig.shared.defaultModel
}
