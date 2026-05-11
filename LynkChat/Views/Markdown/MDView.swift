//
//  MDView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI

struct MDView: View {
    #if os(macOS)
    private static let defaultFontSize: Double = 13
    #else
    private static let defaultFontSize: Double = 17.5
    #endif

    @AppStorage("fontSize") var fontSize: Double = MDView.defaultFontSize
    @Environment(\.markdownSurface) private var surface
    var content: String
    var onHeightChange: ((CGFloat) -> Void)? = nil

    var body: some View {
        SwiftMarkdownView(content, onHeightChange: onHeightChange)
            .markdownFontSize(CGFloat(fontSize))
            .markdownCodeBlockBackground(surface.codeBlockBackground)
            .markdownCodeTheme(light: "atom-one-light", dark: "atom-one-dark")
    }
}

extension MarkdownSurface {
    var codeBlockBackground: Color {
        switch self {
        case .window:
            return Color(PlatformColor.quaternarySystemFill)
        case .glass:
            #if os(macOS)
            return Color(NSColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
                return isDark
                    ? NSColor(white: 1.0, alpha: 0.10)
                    : NSColor(white: 0.0, alpha: 0.05)
            })
            #else
            return Color(UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(white: 1.0, alpha: 0.10)
                    : UIColor(white: 0.0, alpha: 0.05)
            })
            #endif
        }
    }
}

#Preview {
    MDView(content: Message.mockAssistantMessage.content)
        .frame(width: 600, height: 500)
        .padding()
}
