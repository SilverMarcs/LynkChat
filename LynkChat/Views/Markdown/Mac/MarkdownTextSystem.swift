import AppKit

#if os(macOS)
final class MarkdownPlainTextView: NSTextView {
    let markdownTextStorage = NSTextStorage()
    let markdownLayoutManager = MarkdownLayoutManager()
    let markdownTextContainer = NSTextContainer()

    init() {
        markdownLayoutManager.addTextContainer(markdownTextContainer)
        markdownTextStorage.addLayoutManager(markdownLayoutManager)
        super.init(frame: .zero, textContainer: markdownTextContainer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        markdownAncestorMenu(from: self)
    }

    func update(document: MarkdownRenderedDocument) {
        markdownLayoutManager.codeBlocks = document.codeBlocks
        markdownLayoutManager.quoteBlocks = document.quoteBlocks
        markdownTextStorage.setAttributedString(document.attributedString)
    }

    var codeBlockBackgroundColor: NSColor {
        get { markdownLayoutManager.codeBlockBackgroundColor }
        set {
            markdownLayoutManager.codeBlockBackgroundColor = newValue
            needsDisplay = true
        }
    }

    var quoteLineColor: NSColor {
        get { markdownLayoutManager.quoteLineColor }
        set {
            markdownLayoutManager.quoteLineColor = newValue
            needsDisplay = true
        }
    }

    func codeBlockFrames() -> [(codeBlock: MarkdownCodeBlock, frame: NSRect)] {
        markdownLayoutManager.codeBlockFrames(in: markdownTextContainer)
    }
}

final class MarkdownLayoutManager: NSLayoutManager {
    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let verticalPadding: CGFloat = 16
        static let quoteIndentStep: CGFloat = 16
        static let quoteLineWidth: CGFloat = 3
        static let quoteLineInset: CGFloat = 6
        static let quoteVerticalInset: CGFloat = 2
    }

    var codeBlocks: [MarkdownCodeBlock] = []
    var codeBlockBackgroundColor: NSColor = .clear
    var quoteBlocks: [MarkdownQuoteBlock] = []
    var quoteLineColor: NSColor = .clear

    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        drawCodeBlockBackgrounds(forGlyphRange: glyphsToShow, at: origin)
        drawQuoteLines(forGlyphRange: glyphsToShow, at: origin)
    }

    func codeBlockFrames(in textContainer: NSTextContainer) -> [(codeBlock: MarkdownCodeBlock, frame: NSRect)] {
        codeBlocks.compactMap { codeBlock in
            let glyphRange = glyphRange(forCharacterRange: codeBlock.range, actualCharacterRange: nil)
            guard glyphRange.length > 0,
                  let rect = codeBlockRect(forGlyphRange: glyphRange, in: textContainer, at: .zero) else {
                return nil
            }

            return (codeBlock, rect)
        }
    }

    private func drawCodeBlockBackgrounds(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        guard !codeBlocks.isEmpty, let textContainer = textContainers.first else { return }

        let visibleCharacterRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        let visibleCodeBlocks = codeBlocks.filter {
            NSIntersectionRange($0.range, visibleCharacterRange).length > 0
        }

        guard !visibleCodeBlocks.isEmpty else { return }

        codeBlockBackgroundColor.setFill()

        for codeBlock in visibleCodeBlocks {
            let glyphRange = glyphRange(forCharacterRange: codeBlock.range, actualCharacterRange: nil)
            guard glyphRange.length > 0,
                  let blockRect = codeBlockRect(forGlyphRange: glyphRange, in: textContainer, at: origin) else {
                continue
            }

            NSBezierPath(
                roundedRect: blockRect,
                xRadius: Layout.cornerRadius,
                yRadius: Layout.cornerRadius
            ).fill()
        }
    }

    private func codeBlockRect(
        forGlyphRange glyphRange: NSRange,
        in textContainer: NSTextContainer,
        at origin: CGPoint
    ) -> NSRect? {
        var blockRect: NSRect?

        enumerateLineFragments(forGlyphRange: glyphRange) { lineRect, _, _, effectiveGlyphRange, _ in
            guard NSIntersectionRange(effectiveGlyphRange, glyphRange).length > 0 else { return }
            let adjustedRect = lineRect.offsetBy(dx: origin.x, dy: origin.y)
            blockRect = blockRect.map { $0.union(adjustedRect) } ?? adjustedRect
        }

        guard var blockRect else { return nil }

        blockRect.origin.x += textContainer.lineFragmentPadding
        blockRect.size.width = max(0, blockRect.size.width - (textContainer.lineFragmentPadding * 2))
        blockRect.origin.y -= Layout.verticalPadding / 2
        blockRect.size.height += Layout.verticalPadding
        return blockRect.integral
    }

    private func drawQuoteLines(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        guard !quoteBlocks.isEmpty, let textContainer = textContainers.first else { return }

        let visibleCharacterRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        let visibleQuoteBlocks = quoteBlocks.filter {
            NSIntersectionRange($0.range, visibleCharacterRange).length > 0
        }

        guard !visibleQuoteBlocks.isEmpty else { return }

        quoteLineColor.setFill()

        for quoteBlock in visibleQuoteBlocks {
            let glyphRange = glyphRange(forCharacterRange: quoteBlock.range, actualCharacterRange: nil)
            guard glyphRange.length > 0,
                  let blockRect = quoteBlockRect(forGlyphRange: glyphRange, in: textContainer, at: origin) else {
                continue
            }

            for level in 0..<quoteBlock.depth {
                let x = blockRect.minX + Layout.quoteLineInset + (CGFloat(level) * Layout.quoteIndentStep)
                let lineRect = NSRect(
                    x: x,
                    y: blockRect.minY + Layout.quoteVerticalInset,
                    width: Layout.quoteLineWidth,
                    height: max(0, blockRect.height - (Layout.quoteVerticalInset * 2))
                ).integral

                NSBezierPath(
                    roundedRect: lineRect,
                    xRadius: Layout.quoteLineWidth / 2,
                    yRadius: Layout.quoteLineWidth / 2
                ).fill()
            }
        }
    }

    private func quoteBlockRect(
        forGlyphRange glyphRange: NSRange,
        in textContainer: NSTextContainer,
        at origin: CGPoint
    ) -> NSRect? {
        var blockRect: NSRect?

        enumerateLineFragments(forGlyphRange: glyphRange) { lineRect, _, _, effectiveGlyphRange, _ in
            guard NSIntersectionRange(effectiveGlyphRange, glyphRange).length > 0 else { return }
            let adjustedRect = lineRect.offsetBy(dx: origin.x, dy: origin.y)
            blockRect = blockRect.map { $0.union(adjustedRect) } ?? adjustedRect
        }

        guard var blockRect else { return nil }

        blockRect.origin.x += textContainer.lineFragmentPadding
        blockRect.size.width = max(0, blockRect.size.width - (textContainer.lineFragmentPadding * 2))
        return blockRect.integral
    }
}
#endif
