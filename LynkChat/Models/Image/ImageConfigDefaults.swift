//
//  ImageModelConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/12/2024.
//

import SwiftUI

struct ImageConfigDefaults {
    @AppStorage("numImages") var numImages: Int = 1
    @AppStorage("wavespeedApiKey") var wavespeedApiKey: String = ""
    
    @AppStorage("defaultModel") var defaultModel: ImageModel = .flux
    @AppStorage("defaultImageMode") var defaultMode: ImageMode = .editing
}
