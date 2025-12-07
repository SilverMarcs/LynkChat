//
//  ImageModelConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI

struct ImageConfigDefaults {
    @AppStorage("saveToPhotos") var saveToPhotos = true
    
    @AppStorage("defaultModel") var defaultModel: ImageModel = .zImage
    @AppStorage("defaultEditingModel") var defaultEditingModel: ImageEditingModel = .seedream
    
    @AppStorage("wavespeedApiKey") var wavespeedApiKey: String = ""
}
