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
                    .toolbarBackground(Color(hex: "#0c0d0d"), for: .windowToolbar)
            }
            .restorationBehavior(.disabled)
            .defaultSize(.init(width: 1100, height: 850))
            .windowStyle(.hiddenTitleBar)
        } else {
            return Window("Debug", id: WindowID.debugWeb) {
                DebugWebview()
                    .toolbarBackground(Color(hex: "#0c0d0d"), for: .windowToolbar)
            }
            .defaultSize(.init(width: 1100, height: 850))
            .windowStyle(.hiddenTitleBar)
        }
    }
}
