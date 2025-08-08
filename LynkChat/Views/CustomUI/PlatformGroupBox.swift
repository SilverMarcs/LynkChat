//
//  PlatformGroupBox.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/08/2025.
//

import SwiftUI

struct PlatformGroupBox: GroupBoxStyle {
    let radius: CGFloat
    
    init(radius: CGFloat = 24) {
        self.radius = radius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        #if os(macOS)
        GroupBox {
            configuration.content
        } label: {
            configuration.label
        }
        #else
        VStack {
            configuration.content
                .padding(14)
        }
        .background(
            RoundedRectangle(cornerRadius: radius)
                .fill(.background.secondary)
        )
        #endif
    }
}
