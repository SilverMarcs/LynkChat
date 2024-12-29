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
    @Published var hasUserScrolled = false
    @Published var showCamera = false
    
    @AppStorage("finishedInitialSetup") var finishedInitialSetup = false
    
    // Appearance
    @AppStorage("markdownProvider") var markdownProvider: MarkdownProvider = .webview
    @AppStorage("codeBlockTheme") var codeBlockTheme: CodeBlockTheme = .atom
    #if os(macOS)
    @AppStorage("fontSize") var fontSize: Double = 13
    #else
    @AppStorage("fontSize") var fontSize: Double = 17
    #endif
    // General
    @AppStorage("autogenTitle") var autogenTitle: Bool = true
    @AppStorage("enterToSend") var enterToSend: Bool = true
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
    #if DEBUG
    @AppStorage("printDebgLogs") var printDebgLogs = true
    #else
    @AppStorage("printDebgLogs") var printDebgLogs = false
    #endif
    
}
