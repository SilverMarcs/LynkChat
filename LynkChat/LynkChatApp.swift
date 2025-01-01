//
//  LynkChatApp.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct LynkChatApp: App {
    @State private var chatVM: ChatVM = ChatVM()
    @State private var settingsVM: SettingsVM = SettingsVM()
    
    #if !os(macOS)
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
//        #if DEBUG
//        try? Tips.resetDatastore()
//        #endif        
        try? Tips.configure()

        #if os(macOS)
        AppConfig.shared.hideDock = false

        QuickPanelWindow(
            chatVM: chatVM,
            modelContext: globalContainer.mainContext
        )

        #else
        // TODO: find a way to avoid having chatVM in app delegate
        AppDelegate.shared.chatVM = _chatVM.wrappedValue
        #endif
    }
}
