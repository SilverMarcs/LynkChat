//
//  AppSettings.swift
//  LynkChat
//
//  Created by Zabir Raihan on 20/08/2025.
//

import SwiftUI

@Observable class AppSettings {
    static let shared = AppSettings()
    private init() {}
    
    @ObservationIgnored var proxy: ScrollViewProxy?
    var expandColor = false
    var showCamera = false
}
