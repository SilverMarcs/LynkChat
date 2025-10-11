//
//  AppConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

struct AppConfig {
    // Appearance
    #if os(macOS)
    @AppStorage("fontSize") var fontSize: Double = 13
    #else
    @AppStorage("fontSize") var fontSize: Double = 17
    #endif
    
    // General
    @AppStorage("autogenTitle") var autogenTitle: Bool = true
    
    // Onboarding
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    func resetFontSize() {
        #if os(macOS)
        fontSize = 13
        #else
        fontSize = 17
        #endif
    }
    
    // DEBUG
    @AppStorage("myApiKey") var myApiKey: String = ""
    @AppStorage("geminiApiKey") var geminiApiKey: String = ""
    @AppStorage("useLocalhost") var useLocalhost = false
    @AppStorage("printDebgLogs") var printDebgLogs = false
    @AppStorage("sendDebugModel") var sendDebugModel = false
}
