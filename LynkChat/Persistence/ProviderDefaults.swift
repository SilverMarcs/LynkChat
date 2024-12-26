//
//  ProviderDefaults.swift
//  LynkChat
//
//  Created by Zabir Raihan on 07/10/2024.
//

import SwiftUI
import SwiftData

@Model
class ProviderDefaults {
    var defaultProvider: Provider
    var quickProvider: Provider
    
    var imageProvider: ImageProvider

    init(defaultProvider: Provider, quickProvider: Provider, imageProvider: ImageProvider) {
        self.defaultProvider = defaultProvider
        self.quickProvider = quickProvider
        
        self.imageProvider = imageProvider
    }
}
