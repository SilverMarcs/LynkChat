//
//  MenuCommands.swift
//  LynkChat
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData

struct MenuCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        SidebarCommands()
        
//        InspectorCommands()
        
//        TextEditingCommands()
        
//        TextFormattingCommands()
        
//        ToolbarCommands()
        
        CommandGroup(replacing: .appInfo) {
            Button("About LynkChat") {
                openWindow(id: WindowID.about)
            }
        }
        
        CommandGroup(replacing: .help) {
            Button("LynkChat Help") {
                openWindow(id: WindowID.help)
            }
        }
        
        #if os(macOS)
        CommandGroup(before: .appSettings) {
            Button("Settings") {
                openWindow(id: WindowID.settings)
            }
            .keyboardShortcut(",", modifiers: .command)
        }
        #endif
    }
}
