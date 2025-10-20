//
//  ImageModelConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI

struct ImageConfigDefaults {
    @AppStorage("numImages") var numImages: Int = 1
    @AppStorage("saveToPhotos") var saveToPhotos = true
    
    @AppStorage("defaultModel") var defaultModel: ImageModel = .gpt
    @AppStorage("defaultEditingModel") var defaultEditingModel: ImageEditingModel = .seedream
    @AppStorage("defaultVideoModel") var defaultVideoModel: VideoGenerationModel = .seedance
    
    @AppStorage("wavespeedApiKey") var wavespeedApiKey: String = ""
}
