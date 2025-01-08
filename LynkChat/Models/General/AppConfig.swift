//
//  AppConfig.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

class AppConfig: ObservableObject {
    static let shared = AppConfig()
    private init() {}
    
    var proxy: ScrollViewProxy?
    @Published var expandColor = false
    @Published var showCamera = false
    
    @AppStorage("finishedInitialSetup") var finishedInitialSetup = false
    
    // Appearance
    @AppStorage("codeBlockTheme") var codeBlockTheme: CodeBlockTheme = .atom
    #if os(macOS)
    @AppStorage("fontSize") var fontSize: Double = 13
    @AppStorage("markdownProvider") var markdownProvider: MarkdownProvider = .webview
    #else
    @AppStorage("fontSize") var fontSize: Double = 17
    @AppStorage("markdownProvider") var markdownProvider: MarkdownProvider = .basic
    #endif
    
    // General
    @AppStorage("autogenTitle") var autogenTitle: Bool = true
    @AppStorage("enterToSend") var enterToSend: Bool = false
    @AppStorage("hideDock") var hideDock = false
    @AppStorage("onlyOneWindow") var onlyOneWindow = false
    
    // Onboarding
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("hasUsedChatStatusFilter") var hasUsedChatStatusFilter = false
    
    func resetFontSize() {
        #if os(macOS)
        fontSize = 13
        #else
        fontSize = 17
        #endif
    }
    
    // DEBUG
    @AppStorage("myApiKey") var myApiKey: String = ""
    @AppStorage("reset tips") var resetTips = false
    #if DEBUG
    @AppStorage("useLocalhost") var useLocalhost = false
    @AppStorage("printDebgLogs") var printDebgLogs = true
    @AppStorage("sendDebugModel") var sendDebugModel = false
    #else
    @AppStorage("useLocalhost") var useLocalhost = false
    @AppStorage("printDebgLogs") var printDebgLogs = false
    @AppStorage("sendDebugModel") var sendDebugModel = false
    #endif
    @AppStorage("showDebugMenu") var showDebugMenu: Bool = false
}
