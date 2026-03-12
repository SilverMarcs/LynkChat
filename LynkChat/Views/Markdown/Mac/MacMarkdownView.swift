import SwiftUI

#if os(macOS)
struct MacMarkdownView: View {
    let text: String
    let fontSize: CGFloat
    var calculatedHeight: Binding<CGFloat>? = nil

    var body: some View {
        MacMarkdownRepresentable(
            text: text,
            fontSize: fontSize,
            calculatedHeight: calculatedHeight
        )
    }
}
#endif
