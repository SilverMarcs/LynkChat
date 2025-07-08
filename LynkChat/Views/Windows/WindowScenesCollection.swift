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
        
        SettingsWindow()
        
        AboutWindow()
        
        HelpWindow()
        
        DebugWebWindow()
    }
}
