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
    
    @AppStorage("defaultModel") var defaultModel: ImageModel = .flux
}
