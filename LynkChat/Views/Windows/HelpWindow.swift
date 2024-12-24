//
//  HelpWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 16/11/2024.
//

import SwiftUI

struct HelpWindow: Scene {
    var body: some Scene {
        conditionalAboutWindow()
    }
    
    func conditionalAboutWindow() -> some Scene {
        if #available(macOS 15.0, *) {
            return UtilityWindow("Help", id: WindowID.help) {
                GuidesSettings()
                    .frame(width: 400, height: 500)
            }
            .restorationBehavior(.disabled)
            .windowIdealSize(.fitToContent)
        } else {
            return Window("Help", id: WindowID.help) {
                GuidesSettings()
                    .frame(width: 400, height: 500)
            }
        }
    }
}
