import SwiftUI

struct MacMarkdownView: View {
    let text: String
    let fontSize: CGFloat
    var surface: MarkdownSurface = .window
    var isStreaming: Bool = false
    var calculatedHeight: Binding<CGFloat>? = nil

    var body: some View {
        MacMarkdownRepresentable(
            text: text,
            fontSize: fontSize,
            surface: surface,
            isStreaming: isStreaming,
            calculatedHeight: calculatedHeight
        )
    }
}
