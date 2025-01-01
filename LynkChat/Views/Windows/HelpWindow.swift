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
                Text(try! AttributedString(markdown: "Visit [Guides](https://lynkchat.com/products/lynkchat) for more information."))
            }
            .restorationBehavior(.disabled)
            .windowIdealSize(.fitToContent)
        } else {
            return Window("Help", id: WindowID.help) {
                Text(try! AttributedString(markdown: "Visit [Guides](https://lynkchat.com/products/lynkchat) for more information."))
            }
        }
    }
}
