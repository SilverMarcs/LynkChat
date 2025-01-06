//
//  DebugWebWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 07/01/2025.
//

import SwiftUI

struct DebugWebWindow: Scene {
    var body: some Scene {
        conditionalDebugWindow()
    }
    
    func conditionalDebugWindow() -> some Scene {
        if #available(macOS 15.0, *) {
            return Window("Debug", id: WindowID.debugWeb) {
                DebugWebview()
                    .toolbarBackground(Color(hex: "#0e0e11"), for: .windowToolbar)
            }
            .restorationBehavior(.disabled)
            .defaultSize(.init(width: 1200, height: 900))
            .windowStyle(.hiddenTitleBar)
        } else {
            return Window("Debug", id: WindowID.debugWeb) {
                DebugWebview()
            }
            .defaultSize(.init(width: 1200, height: 900))
            .windowStyle(.hiddenTitleBar)
        }
    }
}
