//
//  ImageWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/09/2024.
//

import SwiftUI

struct ImageWindow: Scene {
    var body: some Scene {
        Window("Images", id: WindowID.images) {
            ImageContentView()
        }
        .defaultSize(.init(width: 1200, height: 900))
    }
}
