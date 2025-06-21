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
    @State private var chatVM: ChatVM = ChatVM()
    @State private var settingsVM: SettingsVM = SettingsVM()
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #else
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        Group {
            #if os(macOS)
            WindowScenesCollection()
            #else
            IOSWindow()
            #endif
        }
        .commands { MenuCommands() }
        .environment(chatVM)
        .environment(settingsVM)
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
        AppConfig.shared.hideDock = false
        QuickPanelWindow(chatVM: chatVM)
        #endif
        
        AppDelegate.shared.chatVM = _chatVM.wrappedValue
        LynkChatShortcuts.updateAppShortcutParameters()
    }
}
