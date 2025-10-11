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
        #if DEBUG
        if AppConfig.shared.resetTips {
            try? Tips.resetDatastore()
            AppConfig.shared.resetTips = false
        }
        #endif
        try? Tips.configure()

        #if os(macOS)
        QuickPanelWindow(chatVM: chatVM)
        #endif
    }
}
