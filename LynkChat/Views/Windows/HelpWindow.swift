//
//  HelpWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 16/11/2024.
//

import SwiftUI

struct HelpWindow: Scene {
    var body: some Scene {
        UtilityWindow("Help", id: WindowID.help) {
            Text(try! AttributedString(markdown: "Visit [Guides](https://lynksphere.com/products/lynkchat) for more information."))
        }
        .restorationBehavior(.disabled)
        .windowIdealSize(.fitToContent)
    }
}
