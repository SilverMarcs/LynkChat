//
//  LynkChatApp.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData
import TipKit
import AppIntents

@main
struct LynkChatApp: App {
    #if !os(macOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    @State private var chatVM = ChatVM()
    @State private var mcpConfigVM = MCPConfigVM()
    @State private var modelRegistry = ModelRegistry()
    
    var body: some Scene {
        Group {
            #if os(macOS)
            WindowScenesCollection()
            #else
            IOSWindow()
            #endif
        }
        .environment(chatVM)
        .environment(mcpConfigVM)
        .environment(modelRegistry)
        .commands { MenuCommands() }
        .modelContainer(globalContainer)
    }
    
    init() {
        try? Tips.configure()

        #if os(macOS)
        QuickPanelWindow(chatVM: chatVM)
        #endif
    }
}
