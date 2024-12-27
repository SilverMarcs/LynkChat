//
//  ModelConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI

class ModelConfig: ObservableObject {
    static let shared = ModelConfig()
    private init() {}
    
    @AppStorage("defaultModel") var defaultModel: ChatModel = .claude3_5sonnet
    @AppStorage("quickModel") var quickModel: ChatModel = .claude3_5sonnet
    @AppStorage("titleModel") var titleModel: ChatModel = .claude3_5haiku
    
    @AppStorage("enable_claude3_5sonnet") var enable_claude3_5sonnet: Bool = true
}
