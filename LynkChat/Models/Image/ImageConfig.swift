//
//  ImageConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation
import SwiftData

@Model
class ImageConfig {
    var id: UUID = UUID()
    var date: Date = Date()
    
    @Relationship(deleteRule: .nullify)
    var provider: ImageProvider
    @Relationship(deleteRule: .nullify)
    var model: AIModel
    
    var prompt: String = "" // TODO: must take in init tbh
    var numImages: Int = ImageConfigDefaults.shared.numImages
//    var size: ImagesQuery.Size = ImageConfigDefaults.shared.size
//    var quality: ImagesQuery.Quality = ImageConfigDefaults.shared.quality
//    var style: ImagesQuery.Style = ImageConfigDefaults.shared.style
    
    init(provider: ImageProvider) {
        self.provider = provider
        self.model = provider.model
    }
    
    init(provider: ImageProvider, model: AIModel) {
        self.provider = provider
        self.model = model
    }
}
