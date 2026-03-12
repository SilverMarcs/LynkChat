import AppKit

#if os(macOS)
final class MarkdownPlainTextView: NSTextView {
    let markdownTextStorage = NSTextStorage()
    let markdownLayoutManager = MarkdownLayoutManager()
    let markdownTextContainer = NSTextContainer()

    init() {
        markdownLayoutManager.delegate = markdownLayoutManager
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
        markdownLayoutManager.tableBlocks = document.tableBlocks
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

final class MarkdownLayoutManager: NSLayoutManager, NSLayoutManagerDelegate {
    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let verticalPadding: CGFloat = 16
        static let tableVerticalPadding: CGFloat = 2
        static let quoteIndentStep: CGFloat = 16
        static let quoteLineWidth: CGFloat = 3
        static let quoteLineInset: CGFloat = 6
        static let quoteVerticalInset: CGFloat = 2
    }

    var codeBlocks: [MarkdownCodeBlock] = []
    var codeBlockBackgroundColor: NSColor = .clear
    var quoteBlocks: [MarkdownQuoteBlock] = []
    var quoteLineColor: NSColor = .clear
    var tableBlocks: [MarkdownTableBlock] = []

    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        drawCodeBlockBackgrounds(forGlyphRange: glyphsToShow, at: origin)
        drawTableBackgrounds(forGlyphRange: glyphsToShow, at: origin)
        drawQuoteLines(forGlyphRange: glyphsToShow, at: origin)
    }

    func layoutManager(
        _ layoutManager: NSLayoutManager,
        lineSpacingAfterGlyphAt glyphIndex: Int,
        withProposedLineFragmentRect rect: NSRect
    ) -> CGFloat {
        spacingAfterLineEndingGlyph(at: glyphIndex, keyPath: \.lineSpacing)
    }

    func layoutManager(
        _ layoutManager: NSLayoutManager,
        paragraphSpacingAfterGlyphAt glyphIndex: Int,
        withProposedLineFragmentRect rect: NSRect
    ) -> CGFloat {
        guard lineEndsParagraph(at: glyphIndex) else { return 0 }
        guard !lineEndsDocument(at: glyphIndex) else { return 0 }
        guard let paragraphStyle = paragraphStyle(at: glyphIndex) else { return 0 }
        return paragraphStyle.paragraphSpacing
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

    private func drawTableBackgrounds(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        guard !tableBlocks.isEmpty else { return }

        let visibleCharacterRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        let visibleTables = tableBlocks.filter {
            NSIntersectionRange($0.range, visibleCharacterRange).length > 0
        }

        guard !visibleTables.isEmpty else { return }

        for table in visibleTables {
            let glyphRange = glyphRange(forCharacterRange: table.range, actualCharacterRange: nil)
            guard glyphRange.length > 0 else { continue }

            var lineRects: [NSRect] = []
            enumerateLineFragments(forGlyphRange: glyphRange) { lineRect, _, _, effectiveRange, _ in
                guard NSIntersectionRange(effectiveRange, glyphRange).length > 0 else { return }
                lineRects.append(lineRect.offsetBy(dx: origin.x, dy: origin.y))
            }
            guard !lineRects.isEmpty else { continue }

            let unionRect = lineRects.reduce(lineRects[0]) { $0.union($1) }
            let blockRect = NSRect(
                x: unionRect.minX,
                y: unionRect.minY - Layout.tableVerticalPadding / 2,
                width: table.contentWidth,
                height: unionRect.height + Layout.tableVerticalPadding
            ).integral

            codeBlockBackgroundColor.setFill()
            let bgPath = NSBezierPath(
                roundedRect: blockRect,
                xRadius: Layout.cornerRadius,
                yRadius: Layout.cornerRadius
            )
            bgPath.fill()

            NSColor.labelColor.withAlphaComponent(0.08).setStroke()
            bgPath.lineWidth = 1
            bgPath.stroke()

            let gridColor = NSColor.labelColor.withAlphaComponent(0.06)
            gridColor.setStroke()

            for i in 0..<(lineRects.count - 1) {
                let y = ceil((lineRects[i].maxY + lineRects[i + 1].minY) / 2)
                let linePath = NSBezierPath()
                linePath.move(to: NSPoint(x: blockRect.minX + 1, y: y))
                linePath.line(to: NSPoint(x: blockRect.maxX - 1, y: y))
                linePath.lineWidth = 1
                linePath.stroke()
            }

            for separatorX in table.columnSeparatorPositions {
                let x = ceil(origin.x + separatorX)
                let linePath = NSBezierPath()
                linePath.move(to: NSPoint(x: x, y: blockRect.minY + 1))
                linePath.line(to: NSPoint(x: x, y: blockRect.maxY - 1))
                linePath.lineWidth = 1
                linePath.stroke()
            }
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

    private func spacingAfterLineEndingGlyph(
        at glyphIndex: Int,
        keyPath: KeyPath<NSParagraphStyle, CGFloat>
    ) -> CGFloat {
        guard !lineEndsParagraph(at: glyphIndex) else { return 0 }
        guard let paragraphStyle = paragraphStyle(at: glyphIndex) else { return 0 }
        return paragraphStyle[keyPath: keyPath]
    }

    private func paragraphStyle(at glyphIndex: Int) -> NSParagraphStyle? {
        guard let textStorage else { return nil }
        let characterIndex = characterIndexForGlyph(at: glyphIndex)
        guard characterIndex < textStorage.length else { return nil }
        return textStorage.attribute(.paragraphStyle, at: characterIndex, effectiveRange: nil) as? NSParagraphStyle
    }

    private func lineEndsParagraph(at glyphIndex: Int) -> Bool {
        guard let textStorage else { return true }
        let string = textStorage.string as NSString
        let characterIndex = characterIndexForGlyph(at: glyphIndex)

        guard characterIndex < string.length else { return true }

        if string.character(at: characterIndex).isMarkdownParagraphTerminator {
            return true
        }

        let nextCharacterIndex = characterIndex + 1
        guard nextCharacterIndex < string.length else { return true }
        return string.character(at: nextCharacterIndex).isMarkdownParagraphTerminator
    }

    private func lineEndsDocument(at glyphIndex: Int) -> Bool {
        guard let textStorage else { return true }
        let string = textStorage.string as NSString
        let characterIndex = characterIndexForGlyph(at: glyphIndex)

        guard characterIndex < string.length else { return true }

        if !string.character(at: characterIndex).isMarkdownParagraphTerminator {
            return characterIndex == string.length - 1
        }

        let nextCharacterIndex = characterIndex + 1
        return nextCharacterIndex >= string.length
    }
}

private extension unichar {
    var isMarkdownParagraphTerminator: Bool {
        guard let scalar = UnicodeScalar(self) else { return false }
        return CharacterSet.newlines.contains(scalar)
    }
}
#endif
