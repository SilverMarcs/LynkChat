//
//  ImageModelConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI

class ImageModelConfig: ObservableObject {
    static let shared = ImageModelConfig()
    private init() {}
    
    @AppStorage("numImages") var numImages: Int = 1
    @AppStorage("saveToPhotos") var saveToPhotos = true
    
    @AppStorage("defaultModel") var defaultModel: ImageModel = .flux_schnell
    @AppStorage("quickModel") var quickModel: ImageModel = .dall_e_2
    @AppStorage("titleModel") var titleModel: ImageModel = .dall_e_3
}
