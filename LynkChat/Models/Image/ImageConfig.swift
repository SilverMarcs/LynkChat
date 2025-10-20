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
    var videoModel: VideoGenerationModel
    var prompt: String
    var numImages: Int
    var mode: GenerationMode
    
    init(prompt: String = "") {
        self.prompt = prompt
        
        let defaults = ImageConfigDefaults()
        
        self.model = defaults.defaultModel
        self.editingModel = defaults.defaultEditingModel
        self.videoModel = defaults.defaultVideoModel
        self.numImages = defaults.numImages
        self.mode = .generation
    }
}
