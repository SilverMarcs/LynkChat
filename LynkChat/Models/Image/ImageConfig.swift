//
//  ImageConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation

struct ImageConfig: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var model: ImageModel = ImageModel.flux_schnell
    
    var prompt: String = "" // TODO: must take in init tbh
    var numImages: Int = ImageModelConfig.shared.numImages
}
