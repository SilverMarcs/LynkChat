//
//  AudioWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 07/09/2025.
//

import SwiftUI

struct AudioWindow: Scene {
    var body: some Scene {
        Window("Live", id: WindowID.audio) {
            LiveAudioView()
                .ignoresSafeArea()
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .presentedWindowStyle(.hiddenTitleBar)
                .trackAsMainWindow()
        }
        .restorationBehavior(.disabled)
        .windowLevel(.floating)
        .windowToolbarStyle(.unifiedCompact)
        .defaultSize(.init(width: 450, height: 450))
    }
}
