//
//  AppConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

@Observable class AppSettings {
    static let shared = AppSettings()
    private init() {}
    
    @ObservationIgnored var proxy: ScrollViewProxy?
    var expandColor = false
    var showCamera = false
}

class AppConfig: ObservableObject {
    static let shared = AppConfig()
    private init() {}

    @AppStorage("finishedInitialSetup") var finishedInitialSetup = false
    
    // Appearance
    @AppStorage("codeBlockTheme") var codeBlockTheme: CodeBlockTheme = .atom
    @AppStorage("isMarkdownEnabled") var isMarkdownEnabled: Bool = true
    #if os(macOS)
    @AppStorage("fontSize") var fontSize: Double = 13
    #else
    @AppStorage("fontSize") var fontSize: Double = 17
    #endif
    
    // General
    @AppStorage("autogenTitle") var autogenTitle: Bool = true
    @AppStorage("enterToSend") var enterToSend: Bool = false
    @AppStorage("hideDock") var hideDock = false
    
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
    @AppStorage("reseTips") var resetTips = false
    @AppStorage("showUrlParsingResult") var showUrlParsingResult = false
    @AppStorage("useLocalhost") var useLocalhost = false
    @AppStorage("printDebgLogs") var printDebgLogs = false
    @AppStorage("sendDebugModel") var sendDebugModel = false
    @AppStorage("showDebugMenu") var showDebugMenu: Bool = false
}
