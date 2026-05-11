import SwiftUI

/// Highlight.js theme names used for syntax highlighting in fenced code blocks.
/// Resolved against the view's current appearance (light vs dark).
struct MarkdownCodeTheme: Hashable, Sendable {
    var light: String
    var dark: String

    static let `default` = MarkdownCodeTheme(light: "atom-one-light", dark: "atom-one-dark")
}

/// Public entry point for rendering markdown.
///
/// Configure via view modifiers:
/// ```swift
/// SwiftMarkdownView(text) { height in ... }
///   .markdownFontSize(17)
///   .markdownCodeBlockBackground(Color(.quaternarySystemFill))
///   .markdownCodeTheme(light: "xcode", dark: "atom-one-dark")
/// ```
struct SwiftMarkdownView: View {
    let content: String
    let onHeightChange: ((CGFloat) -> Void)?

    init(_ content: String, onHeightChange: ((CGFloat) -> Void)? = nil) {
        self.content = content
        self.onHeightChange = onHeightChange
    }

    var body: some View {
        MarkdownRepresentable(text: content, onHeightChange: onHeightChange)
    }
}

// MARK: - Environment

extension EnvironmentValues {
    @Entry var markdownFontSize: CGFloat = 13
    @Entry var markdownCodeBlockBackground: Color = Color(PlatformColor.quaternarySystemFill)
    @Entry var markdownCodeTheme: MarkdownCodeTheme = .default
}

// MARK: - Modifiers

extension View {
    func markdownFontSize(_ size: CGFloat) -> some View {
        environment(\.markdownFontSize, size)
    }

    func markdownCodeBlockBackground(_ color: Color) -> some View {
        environment(\.markdownCodeBlockBackground, color)
    }

    func markdownCodeTheme(light: String, dark: String) -> some View {
        environment(\.markdownCodeTheme, MarkdownCodeTheme(light: light, dark: dark))
    }
}
