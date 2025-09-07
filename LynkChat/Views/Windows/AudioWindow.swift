//
//  AudioWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 07/09/2025.
//

import SwiftUI

struct AudioWindow: Scene {
    var body: some Scene {
        Window("Images", id: WindowID.audio) {
            LiveAudioView()
        }
        .defaultSize(.init(width: 450, height: 450))
    }
}
