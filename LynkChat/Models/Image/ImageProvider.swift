//
//  ImageProvider.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import Foundation
import SwiftData

@Model
class ImageProvider: ProviderImageProvider {
    var id: UUID = UUID()
    var name: String
    var baseUrl: String
    var apiKey: String = ""
    var model: AIModel
    
    var models: [AIModel] = []
    
    init(name: String, baseUrl: String, model: AIModel) {
        self.name = name
        self.baseUrl = baseUrl
        self.models = [model]
        self.model = model
    }
    
    var color: String {
        "#3f51b5"
    }
    
    var imageName: String {
        "openai.SFSymbol"
    }
}
