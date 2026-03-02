//
//  ImageModelConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI

struct ImageConfigDefaults {
    @AppStorage("saveToPhotos") var saveToPhotos = true
    
    @AppStorage("defaultImageModel") var defaultModel: ImageModel = .seedreamV50Lite
    @AppStorage("defaultEditingModel") var defaultEditingModel: ImageEditingModel = .seedream
    
    @AppStorage("wavespeedApiKey") var wavespeedApiKey: String = ""
}
