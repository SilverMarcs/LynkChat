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
            Button {
                openWindow(id: WindowID.about)
            } label: {
                Label("About LynkChat", systemImage: "info.circle")
            }
        }

        #if os(macOS)
        CommandGroup(before: .appSettings) {
            Button {
                openWindow(id: WindowID.settings)
            } label: {
                Label("Settings", systemImage: "gearshape")
            }
            .keyboardShortcut(",", modifiers: .command)
        }

        #endif
    }
}
