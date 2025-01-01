//
//  CustomViewModifiers.swift
//  LynkChat
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

extension View {
    func roundedRectangleOverlay(radius: CGFloat = 20, opacity: CGFloat = 1, style: RoundedCornerStyle = .continuous) -> some View {
        self.modifier(RoundedRectangleOverlayModifier(radius: radius, opacity: opacity, style: style))
    }
}


struct RoundedRectangleOverlayModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var radius: CGFloat
    var opacity: CGFloat
    var style: RoundedCornerStyle
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: style)
                #if os(macOS)
                    .stroke(.quaternary, lineWidth: 0.6)
                #elseif os(visionOS)
                    .stroke(Color(.quaternaryLabel), lineWidth: 1)
                #else
                    .stroke(colorScheme == .dark ? Color(.tertiarySystemGroupedBackground) : Color(.tertiaryLabel), lineWidth: 1)
                #endif
                    .opacity(opacity)
            )
    }
}

#Preview {
    TextEditor(text: .constant("Hello, World!"))
        .roundedRectangleOverlay()
}
