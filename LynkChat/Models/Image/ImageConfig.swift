//
//  ImageConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation

struct ImageConfig: Identifiable, Codable, Sendable {
    var id: UUID = UUID()

    var model: ImageModel
    var editingModel: ImageEditingModel
    var prompt: String
    
    init(prompt: String = "") {
        self.prompt = prompt
        
        let defaults = ImageConfigDefaults()
        
        self.model = defaults.defaultModel
        self.editingModel = .seedream
    }
}
