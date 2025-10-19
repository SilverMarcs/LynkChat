//
//  AppConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

struct AppConfig {
    // General
    @AppStorage("autogenTitle") var autogenTitle: Bool = true
    
    @AppStorage("geminiApiKey") var geminiApiKey: String = ""
}
