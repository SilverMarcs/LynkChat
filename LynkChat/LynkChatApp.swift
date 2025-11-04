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
    
    var body: some Scene {
        Group {
            #if os(macOS)
            WindowScenesCollection()
            #else
            IOSWindow()
            #endif
        }
        .environment(chatVM)
        .commands { MenuCommands() }
        .modelContainer(globalContainer)
    }
    
    init() {
        try? Tips.configure()

        #if os(macOS)
        // Ensure Dock is hidden at launch until a main window appears
        DockVisibilityManager.shared.updateActivationPolicy()
        QuickPanelWindow(chatVM: chatVM)
        #endif
    }
}
