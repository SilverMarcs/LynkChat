//
//  WindowScenesCollection.swift
//  LynkChat
//
//  Created by Zabir Raihan on 24/12/2024.
//

import SwiftUI

struct WindowScenesCollection: Scene {
    var body: some Scene {
        ChatWindow()
        ImageWindow()
        conditionalSettingsWindow()
        AboutWindow()
        HelpWindow()
    }
    
    func conditionalSettingsWindow() -> some Scene {
         if #available(macOS 15.0, *) {
             return SettingsWindow()
                     .restorationBehavior(.disabled)
         } else {
             return SettingsWindow()
         }
     }

    func conditionalAboutWindow() -> some Scene {
        if #available(macOS 15.0, *) {
            return AboutWindow()
                .restorationBehavior(.disabled)
        } else {
            return AboutWindow()
        }
    }

    func conditionalChatWindow() -> some Scene {
        if #available(macOS 15.0, *) {
            return ChatWindow()
                .restorationBehavior(.disabled)
        } else {
            return ChatWindow()
        }
    }
}
