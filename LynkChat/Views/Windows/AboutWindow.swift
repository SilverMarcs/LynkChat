//
//  AboutWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 08/11/2024.
//

import SwiftUI

struct AboutWindow: Scene {
    var body: some Scene {
        Window("About", id: WindowID.about) {
            AboutSettings()
                .padding(.top, -19)
                .padding(.horizontal, 5)
                .scrollDisabled(true)
                .scrollContentBackground(.hidden)
                .frame(minWidth: 325, maxWidth: 325, minHeight: 405, maxHeight: 405)
                .windowMinimizeBehavior(.disabled)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .restorationBehavior(.disabled)
    }
}
