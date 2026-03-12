import SwiftUI

#if os(macOS)
final class MarkdownRenderCache {
    let text: String
    let fontSize: CGFloat
    let themeName: String
    let document: MarkdownRenderedDocument

    init(text: String, fontSize: CGFloat, themeName: String, document: MarkdownRenderedDocument) {
        self.text = text
        self.fontSize = fontSize
        self.themeName = themeName
        self.document = document
    }
}

struct MacMarkdownRepresentable: NSViewRepresentable {
    let text: String
    let fontSize: CGFloat
    var calculatedHeight: Binding<CGFloat>?

    final class Coordinator {
        private var cachedRender: MarkdownRenderCache?

        func render(for text: String, fontSize: CGFloat, themeName: String) -> MarkdownRenderCache {
            if let cachedRender,
               cachedRender.text == text,
               cachedRender.fontSize == fontSize,
               cachedRender.themeName == themeName {
                return cachedRender
            }

            let render = MarkdownRenderCache(
                text: text,
                fontSize: fontSize,
                themeName: themeName,
                document: MacMarkdownRenderer(fontSize: fontSize, themeName: themeName).render(text)
            )
            cachedRender = render
            return render
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> MarkdownContainerView {
        MarkdownContainerView()
    }

    func updateNSView(_ nsView: MarkdownContainerView, context: Context) {
        nsView.renderProvider = { renderText, renderFontSize, themeName in
            context.coordinator.render(for: renderText, fontSize: renderFontSize, themeName: themeName)
        }
        nsView.onHeightChange = { newHeight in
            guard let calculatedHeight, calculatedHeight.wrappedValue != newHeight else { return }
            calculatedHeight.wrappedValue = newHeight
        }
        nsView.update(text: text, fontSize: fontSize)
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: MarkdownContainerView,
        context: Context
    ) -> CGSize? {
        guard let width = proposal.width else { return nil }
        nsView.renderProvider = { renderText, renderFontSize, themeName in
            context.coordinator.render(for: renderText, fontSize: renderFontSize, themeName: themeName)
        }
        nsView.update(text: text, fontSize: fontSize)
        return nsView.measuredSize(for: width)
    }
}
#endif
