//import SwiftUI
//
//#if os(macOS)
//import AppKit
//import Foundation
//import Highlightr
//
//struct MacMarkdownView: View {
//    let text: String
//    let fontSize: CGFloat
//    var calculatedHeight: Binding<CGFloat>? = nil
//
//    var body: some View {
//        MacMarkdownRepresentable(
//            text: text,
//            fontSize: fontSize,
//            calculatedHeight: calculatedHeight
//        )
//    }
//}
//
//private final class MarkdownRenderCache {
//    let text: String
//    let fontSize: CGFloat
//    let themeName: String
//    let document: MarkdownRenderedDocument
//
//    init(text: String, fontSize: CGFloat, themeName: String, document: MarkdownRenderedDocument) {
//        self.text = text
//        self.fontSize = fontSize
//        self.themeName = themeName
//        self.document = document
//    }
//}
//
//private struct MacMarkdownRepresentable: NSViewRepresentable {
//    let text: String
//    let fontSize: CGFloat
//    var calculatedHeight: Binding<CGFloat>?
//
//    final class Coordinator {
//        private var cachedRender: MarkdownRenderCache?
//
//        func render(for text: String, fontSize: CGFloat, themeName: String) -> MarkdownRenderCache {
//            if let cachedRender,
//               cachedRender.text == text,
//               cachedRender.fontSize == fontSize,
//               cachedRender.themeName == themeName {
//                return cachedRender
//            }
//
//            let render = MarkdownRenderCache(
//                text: text,
//                fontSize: fontSize,
//                themeName: themeName,
//                document: MacMarkdownRenderer(fontSize: fontSize, themeName: themeName).render(text)
//            )
//            cachedRender = render
//            return render
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//
//    func makeNSView(context: Context) -> MarkdownContainerView {
//        MarkdownContainerView()
//    }
//
//    func updateNSView(_ nsView: MarkdownContainerView, context: Context) {
//        nsView.renderProvider = { renderText, renderFontSize, themeName in
//            context.coordinator.render(for: renderText, fontSize: renderFontSize, themeName: themeName)
//        }
//        nsView.onHeightChange = { newHeight in
//            guard let calculatedHeight, calculatedHeight.wrappedValue != newHeight else { return }
//            calculatedHeight.wrappedValue = newHeight
//        }
//        nsView.update(text: text, fontSize: fontSize)
//    }
//
//    func sizeThatFits(_ proposal: ProposedViewSize, nsView: MarkdownContainerView, context: Context) -> CGSize? {
//        guard let width = proposal.width else { return nil }
//        nsView.renderProvider = { renderText, renderFontSize, themeName in
//            context.coordinator.render(for: renderText, fontSize: renderFontSize, themeName: themeName)
//        }
//        nsView.update(text: text, fontSize: fontSize)
//        return nsView.measuredSize(for: width)
//    }
//}
//
//private final class MarkdownContainerView: NSView {
//    private enum Layout {
//        static let copyButtonInset: CGFloat = 10
//        static let copyButtonSize: CGFloat = 28
//    }
//
//    private let textView = MarkdownPlainTextView()
//    private var currentWidth: CGFloat = 0
//    private var lastReportedHeight: CGFloat = 0
//    private var lastMeasuredSize: CGSize = .zero
//    private var currentRender: MarkdownRenderCache?
//    private var currentThemeName: String?
//    private var sourceText = ""
//    private var sourceFontSize: CGFloat = 0
//    private var needsMeasurement = false
//    private var codeBlockButtons: [Int: NSButton] = [:]
//    var renderProvider: ((String, CGFloat, String) -> MarkdownRenderCache)?
//    var onHeightChange: ((CGFloat) -> Void)?
//
//    override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//        translatesAutoresizingMaskIntoConstraints = false
//
//        textView.drawsBackground = false
//        textView.isEditable = false
//        textView.isSelectable = true
//        textView.isRichText = true
//        textView.importsGraphics = false
//        textView.textContainerInset = .zero
//        textView.markdownTextContainer.lineFragmentPadding = 0
//        textView.markdownTextContainer.widthTracksTextView = true
//        textView.isHorizontallyResizable = false
//        textView.isVerticallyResizable = true
//        textView.translatesAutoresizingMaskIntoConstraints = false
//
//        addSubview(textView)
//
//        let widthConstraint = textView.widthAnchor.constraint(equalToConstant: 0)
//        self.widthConstraint = widthConstraint
//
//        NSLayoutConstraint.activate([
//            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            textView.topAnchor.constraint(equalTo: topAnchor),
//            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            widthConstraint
//        ])
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidChangeEffectiveAppearance() {
//        super.viewDidChangeEffectiveAppearance()
//
//        let themeName = colorSchemeThemeName
//        guard currentThemeName != themeName else { return }
//        currentThemeName = themeName
//        updateAppearance()
//        refreshRenderIfNeeded(force: true)
//    }
//
//    func update(text: String, fontSize: CGFloat) {
//        sourceText = text
//        sourceFontSize = fontSize
//        refreshRenderIfNeeded(force: false)
//    }
//
//    func measuredSize(for width: CGFloat) -> CGSize {
//        recalculateIfNeeded(for: width, reportHeight: false)
//        return lastMeasuredSize
//    }
//
//    override func layout() {
//        super.layout()
//
//        let width = bounds.width > 0 ? bounds.width : currentWidth
//        guard width > 0 else { return }
//
//        recalculateIfNeeded(for: width, reportHeight: true)
//        layoutCodeBlockButtons()
//    }
//
//    override var intrinsicContentSize: NSSize {
//        NSSize(width: lastMeasuredSize.width, height: lastMeasuredSize.height)
//    }
//
//    private var widthConstraint: NSLayoutConstraint?
//
//    private func refreshRenderIfNeeded(force: Bool) {
//        let themeName = colorSchemeThemeName
//        currentThemeName = themeName
//
//        guard let renderProvider else {
//            recalculateIfNeeded(for: currentWidth, reportHeight: true)
//            return
//        }
//
//        let render = renderProvider(sourceText, sourceFontSize, themeName)
//        updateAppearance()
//
//        guard force || currentRender !== render else {
//            recalculateIfNeeded(for: currentWidth, reportHeight: true)
//            return
//        }
//
//        currentRender = render
//        textView.update(document: render.document)
//        syncCodeBlockButtons(with: render.document.codeBlocks)
//        needsMeasurement = true
//        needsLayout = true
//        invalidateIntrinsicContentSize()
//        recalculateIfNeeded(for: currentWidth, reportHeight: true)
//        layoutCodeBlockButtons()
//    }
//
//    private func updateAppearance() {
//        textView.codeBlockBackgroundColor = codeBlockBackgroundColor
//        textView.quoteLineColor = quoteLineColor
//        updateCopyButtonAppearance()
//    }
//
//    private func recalculateIfNeeded(for width: CGFloat, reportHeight: Bool) {
//        let resolvedWidth = ceil(width)
//        guard resolvedWidth > 0 else { return }
//
//        currentWidth = resolvedWidth
//
//        guard needsMeasurement || lastMeasuredSize.width != resolvedWidth else {
//            if reportHeight {
//                reportHeightIfNeeded(lastMeasuredSize.height)
//            }
//            return
//        }
//
//        widthConstraint?.constant = resolvedWidth
//        let measuredHeight = measureHeight()
//        lastMeasuredSize = CGSize(width: resolvedWidth, height: measuredHeight)
//        needsMeasurement = false
//
//        if reportHeight {
//            reportHeightIfNeeded(measuredHeight)
//        }
//    }
//
//    private func measureHeight() -> CGFloat {
//        guard currentWidth > 0 else { return 0 }
//
//        textView.frame.size.width = currentWidth
//        textView.markdownTextContainer.containerSize = CGSize(
//            width: currentWidth,
//            height: CGFloat.greatestFiniteMagnitude
//        )
//        textView.markdownLayoutManager.ensureLayout(for: textView.markdownTextContainer)
//        let usedRect = textView.markdownLayoutManager.usedRect(for: textView.markdownTextContainer)
//        return ceil(usedRect.height)
//    }
//
//    private func reportHeightIfNeeded(_ measuredHeight: CGFloat) {
//        guard measuredHeight > 0, measuredHeight != lastReportedHeight else { return }
//
//        lastReportedHeight = measuredHeight
//        Task { @MainActor in
//            self.onHeightChange?(measuredHeight)
//        }
//    }
//
//    private func syncCodeBlockButtons(with codeBlocks: [MarkdownCodeBlock]) {
//        let nextIDs = Set(codeBlocks.map(\.id))
//
//        for id in codeBlockButtons.keys where !nextIDs.contains(id) {
//            codeBlockButtons[id]?.removeFromSuperview()
//            codeBlockButtons[id] = nil
//        }
//
//        for codeBlock in codeBlocks where codeBlockButtons[codeBlock.id] == nil {
//            let button = NSButton(
//                image: NSImage(
//                    systemSymbolName: "clipboard",
//                    accessibilityDescription: "Copy code"
//                ) ?? NSImage(),
//                target: self,
//                action: #selector(copyCodeBlock(_:))
//            )
//            button.identifier = NSUserInterfaceItemIdentifier(String(codeBlock.id))
//            button.imagePosition = .imageOnly
//            button.bezelStyle = .regularSquare
//            button.controlSize = .small
//            button.translatesAutoresizingMaskIntoConstraints = true
//            button.wantsLayer = true
//            button.layer?.cornerRadius = 8
//            addSubview(button)
//            codeBlockButtons[codeBlock.id] = button
//        }
//
//        updateCopyButtonAppearance()
//    }
//
//    private func updateCopyButtonAppearance() {
//        for button in codeBlockButtons.values {
//            button.contentTintColor = .labelColor
//            button.layer?.backgroundColor = .clear
//        }
//    }
//
//    private func layoutCodeBlockButtons() {
//        let codeBlockRects = Dictionary(
//            uniqueKeysWithValues: textView.codeBlockFrames().map { ($0.codeBlock.id, $0.frame) }
//        )
//
//        for (id, button) in codeBlockButtons {
//            guard let codeBlockRect = codeBlockRects[id] else {
//                button.isHidden = true
//                continue
//            }
//
//            let convertedRect = textView.convert(codeBlockRect, to: self)
//            button.frame = NSRect(
//                x: convertedRect.maxX - Layout.copyButtonSize - Layout.copyButtonInset,
//                y: convertedRect.minY + Layout.copyButtonInset,
//                width: Layout.copyButtonSize,
//                height: Layout.copyButtonSize
//            ).integral
//            button.isHidden = false
//        }
//    }
//
//    @objc
//    private func copyCodeBlock(_ sender: NSButton) {
//        guard let identifier = sender.identifier?.rawValue,
//              let codeBlockID = Int(identifier),
//              let codeBlock = currentRender?.document.codeBlocks.first(where: { $0.id == codeBlockID }) else {
//            return
//        }
//
//        NSPasteboard.general.clearContents()
//        NSPasteboard.general.setString(codeBlock.content, forType: .string)
//    }
//
//    private var colorSchemeThemeName: String {
//        switch effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
//        case .darkAqua:
//            "atom-one-dark"
//        default:
//            "atom-one-light"
//        }
//    }
//
//    private var codeBlockBackgroundColor: NSColor {
//        let windowColor = NSColor.windowBackgroundColor.usingColorSpace(.deviceRGB) ?? .windowBackgroundColor
//        let shadowColor = NSColor.black.withAlphaComponent(0.28).usingColorSpace(.deviceRGB) ?? .black
//        let lightModeShadow = NSColor.labelColor.withAlphaComponent(0.08).usingColorSpace(.deviceRGB) ?? .labelColor
//
//        switch effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
//        case .darkAqua:
//            return windowColor.blended(withFraction: 0.14, of: shadowColor) ?? windowColor
//        default:
//            return windowColor.blended(withFraction: 0.06, of: lightModeShadow) ?? windowColor
//        }
//    }
//
//    private var quoteLineColor: NSColor {
//        switch effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
//        case .darkAqua:
//            return NSColor.tertiaryLabelColor.withAlphaComponent(0.4)
//        default:
//            return NSColor.secondaryLabelColor.withAlphaComponent(0.45)
//        }
//    }
//}
//
//private func markdownAncestorMenu(from view: NSView) -> NSMenu? {
//    var currentView = unsafe view.superview
//
//    while let candidate = currentView {
//        if let menu = candidate.menu {
//            return menu
//        }
//
//        currentView = unsafe candidate.superview
//    }
//
//    return nil
//}
//
//private final class MarkdownPlainTextView: NSTextView {
//    let markdownTextStorage = NSTextStorage()
//    let markdownLayoutManager = MarkdownLayoutManager()
//    let markdownTextContainer = NSTextContainer()
//
//    init() {
//        markdownLayoutManager.addTextContainer(markdownTextContainer)
//        markdownTextStorage.addLayoutManager(markdownLayoutManager)
//        super.init(frame: .zero, textContainer: markdownTextContainer)
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func menu(for event: NSEvent) -> NSMenu? {
//        markdownAncestorMenu(from: self)
//    }
//
//    func update(document: MarkdownRenderedDocument) {
//        markdownLayoutManager.codeBlocks = document.codeBlocks
//        markdownLayoutManager.quoteBlocks = document.quoteBlocks
//        markdownTextStorage.setAttributedString(document.attributedString)
//    }
//
//    var codeBlockBackgroundColor: NSColor {
//        get { markdownLayoutManager.codeBlockBackgroundColor }
//        set {
//            markdownLayoutManager.codeBlockBackgroundColor = newValue
//            needsDisplay = true
//        }
//    }
//
//    var quoteLineColor: NSColor {
//        get { markdownLayoutManager.quoteLineColor }
//        set {
//            markdownLayoutManager.quoteLineColor = newValue
//            needsDisplay = true
//        }
//    }
//
//    func codeBlockFrames() -> [(codeBlock: MarkdownCodeBlock, frame: NSRect)] {
//        markdownLayoutManager.codeBlockFrames(in: markdownTextContainer)
//    }
//}
//
//private final class MarkdownLayoutManager: NSLayoutManager {
//    private enum Layout {
//        static let cornerRadius: CGFloat = 12
//        static let verticalPadding: CGFloat = 16
//        static let quoteIndentStep: CGFloat = 16
//        static let quoteLineWidth: CGFloat = 3
//        static let quoteLineInset: CGFloat = 6
//        static let quoteVerticalInset: CGFloat = 2
//    }
//
//    var codeBlocks: [MarkdownCodeBlock] = []
//    var codeBlockBackgroundColor: NSColor = .clear
//    var quoteBlocks: [MarkdownQuoteBlock] = []
//    var quoteLineColor: NSColor = .clear
//
//    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
//        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
//        drawCodeBlockBackgrounds(forGlyphRange: glyphsToShow, at: origin)
//        drawQuoteLines(forGlyphRange: glyphsToShow, at: origin)
//    }
//
//    private func drawCodeBlockBackgrounds(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
//        guard !codeBlocks.isEmpty, let textContainer = textContainers.first else { return }
//
//        let visibleCharacterRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
//        let visibleCodeBlocks = codeBlocks.filter {
//            NSIntersectionRange($0.range, visibleCharacterRange).length > 0
//        }
//
//        guard !visibleCodeBlocks.isEmpty else { return }
//
//        codeBlockBackgroundColor.setFill()
//
//        for codeBlock in visibleCodeBlocks {
//            let glyphRange = glyphRange(forCharacterRange: codeBlock.range, actualCharacterRange: nil)
//            guard glyphRange.length > 0,
//                  let blockRect = codeBlockRect(forGlyphRange: glyphRange, in: textContainer, at: origin) else {
//                continue
//            }
//
//            NSBezierPath(
//                roundedRect: blockRect,
//                xRadius: Layout.cornerRadius,
//                yRadius: Layout.cornerRadius
//            ).fill()
//        }
//    }
//
//    private func codeBlockRect(
//        forGlyphRange glyphRange: NSRange,
//        in textContainer: NSTextContainer,
//        at origin: CGPoint
//    ) -> NSRect? {
//        var blockRect: NSRect?
//
//        enumerateLineFragments(forGlyphRange: glyphRange) { lineRect, _, _, effectiveGlyphRange, _ in
//            guard NSIntersectionRange(effectiveGlyphRange, glyphRange).length > 0 else { return }
//            let adjustedRect = lineRect.offsetBy(dx: origin.x, dy: origin.y)
//            blockRect = blockRect.map { $0.union(adjustedRect) } ?? adjustedRect
//        }
//
//        guard var blockRect else { return nil }
//
//        blockRect.origin.x += textContainer.lineFragmentPadding
//        blockRect.size.width = max(0, blockRect.size.width - (textContainer.lineFragmentPadding * 2))
//        blockRect.origin.y -= Layout.verticalPadding / 2
//        blockRect.size.height += Layout.verticalPadding
//        return blockRect.integral
//    }
//
//    private func drawQuoteLines(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
//        guard !quoteBlocks.isEmpty, let textContainer = textContainers.first else { return }
//
//        let visibleCharacterRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
//        let visibleQuoteBlocks = quoteBlocks.filter {
//            NSIntersectionRange($0.range, visibleCharacterRange).length > 0
//        }
//
//        guard !visibleQuoteBlocks.isEmpty else { return }
//
//        quoteLineColor.setFill()
//
//        for quoteBlock in visibleQuoteBlocks {
//            let glyphRange = glyphRange(forCharacterRange: quoteBlock.range, actualCharacterRange: nil)
//            guard glyphRange.length > 0,
//                  let blockRect = quoteBlockRect(forGlyphRange: glyphRange, in: textContainer, at: origin) else {
//                continue
//            }
//
//            for level in 0..<quoteBlock.depth {
//                let x = blockRect.minX + Layout.quoteLineInset + (CGFloat(level) * Layout.quoteIndentStep)
//                let lineRect = NSRect(
//                    x: x,
//                    y: blockRect.minY + Layout.quoteVerticalInset,
//                    width: Layout.quoteLineWidth,
//                    height: max(0, blockRect.height - (Layout.quoteVerticalInset * 2))
//                ).integral
//
//                NSBezierPath(
//                    roundedRect: lineRect,
//                    xRadius: Layout.quoteLineWidth / 2,
//                    yRadius: Layout.quoteLineWidth / 2
//                ).fill()
//            }
//        }
//    }
//
//    private func quoteBlockRect(
//        forGlyphRange glyphRange: NSRange,
//        in textContainer: NSTextContainer,
//        at origin: CGPoint
//    ) -> NSRect? {
//        var blockRect: NSRect?
//
//        enumerateLineFragments(forGlyphRange: glyphRange) { lineRect, _, _, effectiveGlyphRange, _ in
//            guard NSIntersectionRange(effectiveGlyphRange, glyphRange).length > 0 else { return }
//            let adjustedRect = lineRect.offsetBy(dx: origin.x, dy: origin.y)
//            blockRect = blockRect.map { $0.union(adjustedRect) } ?? adjustedRect
//        }
//
//        guard var blockRect else { return nil }
//
//        blockRect.origin.x += textContainer.lineFragmentPadding
//        blockRect.size.width = max(0, blockRect.size.width - (textContainer.lineFragmentPadding * 2))
//        return blockRect.integral
//    }
//
//    func codeBlockFrames(in textContainer: NSTextContainer) -> [(codeBlock: MarkdownCodeBlock, frame: NSRect)] {
//        codeBlocks.compactMap { codeBlock in
//            let glyphRange = glyphRange(forCharacterRange: codeBlock.range, actualCharacterRange: nil)
//            guard glyphRange.length > 0,
//                  let rect = codeBlockRect(forGlyphRange: glyphRange, in: textContainer, at: .zero) else {
//                return nil
//            }
//
//            return (codeBlock, rect)
//        }
//    }
//}
//
//private struct MarkdownRenderedDocument {
//    let attributedString: NSAttributedString
//    let codeBlocks: [MarkdownCodeBlock]
//    let quoteBlocks: [MarkdownQuoteBlock]
//}
//
//private struct MarkdownCodeBlock {
//    let id: Int
//    let range: NSRange
//    let content: String
//}
//
//private struct MarkdownQuoteBlock {
//    let range: NSRange
//    let depth: Int
//    let identity: Int
//}
//
//private struct MacMarkdownRenderer {
//    private enum Segment {
//        case markdown(String)
//        case codeBlock(String, language: String?)
//    }
//
//    private struct RenderedTextUnit {
//        let attributedString: NSAttributedString
//        let context: BlockContext
//    }
//
//    private struct BlockContext: Equatable {
//        enum Kind: Equatable {
//            case paragraph
//            case heading(Int)
//            case listItem(ListContext)
//            case thematicBreak
//        }
//
//        struct ListContext: Equatable {
//            enum Marker: Equatable {
//                case bullet
//                case ordered(Int)
//            }
//
//            let marker: Marker
//            let level: Int
//            let groupIdentity: Int
//        }
//
//        let kind: Kind
//        let quoteDepth: Int
//        let quoteIdentity: Int?
//        let blockIdentity: Int
//    }
//
//    private enum ListMarker {
//        case bullet
//        case ordered(Int)
//    }
//
//    private struct MarkdownListContext {
//        let marker: ListMarker
//        let level: Int
//        let groupIdentity: Int
//    }
//
//    private struct MarkdownPresentationContext {
//        enum Kind {
//            case paragraph
//            case heading(Int)
//            case thematicBreak
//        }
//
//        let kind: Kind
//        let quoteDepth: Int
//        let quoteIdentity: Int?
//        let blockIdentity: Int
//        let listContext: MarkdownListContext?
//    }
//
//    private let bodyFontSize: CGFloat
//    private let codeFontSize: CGFloat
//    private let themeName: String
//
//    init(fontSize: CGFloat, themeName: String) {
//        bodyFontSize = max(fontSize, 13)
//        codeFontSize = max(bodyFontSize - 1, 12)
//        self.themeName = themeName
//    }
//
//    func render(_ markdown: String) -> MarkdownRenderedDocument {
//        let output = NSMutableAttributedString()
//        var codeBlocks: [MarkdownCodeBlock] = []
//        var quoteBlocks: [MarkdownQuoteBlock] = []
//        var nextCodeBlockID = 0
//
//        for segment in parseSegments(markdown) {
//            let attributedSegment: NSAttributedString?
//
//            switch segment {
//            case .markdown(let markdown):
//                attributedSegment = renderedMarkdownSegment(from: markdown)
//            case .codeBlock(let code, let language):
//                attributedSegment = renderedCodeBlock(
//                    content: code,
//                    language: language,
//                    blockID: nextCodeBlockID
//                )
//                nextCodeBlockID += 1
//            }
//
//            guard let attributedSegment, attributedSegment.length > 0 else { continue }
//
//            if output.length > 0 {
//                output.append(NSAttributedString(string: "\n\n"))
//            }
//
//            let range = NSRange(location: output.length, length: attributedSegment.length)
//            output.append(attributedSegment)
//
//            if case .codeBlock(let content, _) = segment {
//                codeBlocks.append(
//                    MarkdownCodeBlock(
//                        id: nextCodeBlockID - 1,
//                        range: range,
//                        content: content
//                    )
//                )
//            }
//
//            if case .markdown(let markdownSegment) = segment {
//                mergeQuoteBlocks(
//                    &quoteBlocks,
//                    with: renderedQuoteBlocks(
//                        from: markdownSegment,
//                        in: attributedSegment,
//                        at: range.location
//                    )
//                )
//            }
//        }
//
//        return MarkdownRenderedDocument(
//            attributedString: output,
//            codeBlocks: codeBlocks,
//            quoteBlocks: quoteBlocks
//        )
//    }
//
//    private func renderedMarkdownSegment(from markdown: String) -> NSAttributedString? {
//        guard !markdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            return nil
//        }
//
//        let attributedString = styledMarkdown(markdown)
//        guard attributedString.length > 0 else { return nil }
//        return attributedString
//    }
//
//    private func renderedCodeBlock(content: String, language: String?, blockID: Int) -> NSAttributedString {
//        let highlighter = Highlightr()
//        highlighter?.setTheme(to: themeName)
//
//        let codeFont = NSFont.monospacedSystemFont(ofSize: codeFontSize, weight: .regular)
//        let output: NSMutableAttributedString
//
//        if let highlighted = highlighter?.highlight(content, as: language) {
//            output = NSMutableAttributedString(attributedString: highlighted)
//        } else {
//            output = NSMutableAttributedString(
//                string: content,
//                attributes: [.foregroundColor: NSColor.labelColor]
//            )
//        }
//
//        output.addAttributes([
//            .font: codeFont,
//            .paragraphStyle: codeBlockParagraphStyle(),
//            .markdownCodeBlockID: blockID
//        ], range: output.fullRange)
//
//        return output
//    }
//
//    private func parseSegments(_ markdown: String) -> [Segment] {
//        let lines = markdown.components(separatedBy: .newlines)
//        var segments: [Segment] = []
//        var markdownLines: [String] = []
//        var index = 0
//
//        func flushMarkdownLines() {
//            let chunk = markdownLines.joined(separator: "\n")
//            guard !chunk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//                markdownLines.removeAll(keepingCapacity: true)
//                return
//            }
//
//            segments.append(.markdown(chunk))
//            markdownLines.removeAll(keepingCapacity: true)
//        }
//
//        while index < lines.count {
//            let line = lines[index]
//            let trimmed = line.trimmingCharacters(in: .whitespaces)
//
//            if trimmed.hasPrefix("```") {
//                flushMarkdownLines()
//
//                let language = parseCodeBlockLanguage(from: trimmed)
//                var codeLines: [String] = []
//                index += 1
//
//                while index < lines.count, lines[index].trimmingCharacters(in: .whitespaces) != "```" {
//                    codeLines.append(lines[index])
//                    index += 1
//                }
//
//                if index < lines.count {
//                    index += 1
//                }
//
//                segments.append(.codeBlock(codeLines.joined(separator: "\n"), language: language))
//                continue
//            }
//
//            markdownLines.append(line)
//            index += 1
//        }
//
//        flushMarkdownLines()
//        return segments
//    }
//
//    private func parseCodeBlockLanguage(from trimmedFenceLine: String) -> String? {
//        let languageHint = trimmedFenceLine
//            .dropFirst(3)
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//
//        guard !languageHint.isEmpty else {
//            return nil
//        }
//
//        return languageHint
//            .split(whereSeparator: \.isWhitespace)
//            .first
//            .map(String.init)
//    }
//
//    private func styledMarkdown(_ markdown: String) -> NSAttributedString {
//        let parsed: NSMutableAttributedString
//
//        if let attributed = try? NSAttributedString(
//            markdown: markdown,
//            options: .init(
//                allowsExtendedAttributes: true,
//                interpretedSyntax: .full,
//                failurePolicy: .returnPartiallyParsedIfPossible
//            ),
//            baseURL: nil
//        ) {
//            parsed = NSMutableAttributedString(attributedString: attributed)
//        } else {
//            parsed = NSMutableAttributedString(string: markdown)
//        }
//
//        let units = renderedTextUnits(from: parsed)
//        let output = NSMutableAttributedString()
//        var index = 0
//
//        while index < units.count {
//            let unit = units[index]
//
//            switch unit.context.kind {
//            case .listItem(let listContext):
//                if output.length > 0 {
//                    output.append(NSAttributedString(string: "\n\n"))
//                }
//
//                var isFirstItem = true
//                while index < units.count {
//                    guard case .listItem(let candidateContext) = units[index].context.kind,
//                          candidateContext.groupIdentity == listContext.groupIdentity else {
//                        break
//                    }
//
//                    if !isFirstItem {
//                        output.append(NSAttributedString(string: "\n"))
//                    }
//
//                    output.append(styledListItem(units[index]))
//                    isFirstItem = false
//                    index += 1
//                }
//
//            default:
//                if output.length > 0 {
//                    output.append(NSAttributedString(string: "\n\n"))
//                }
//
//                output.append(styledBlock(unit))
//                index += 1
//            }
//        }
//
//        return output
//    }
//
//    private func renderedTextUnits(from attributedString: NSAttributedString) -> [RenderedTextUnit] {
//        let fullRange = attributedString.fullRange
//        guard fullRange.length > 0 else { return [] }
//
//        var units: [RenderedTextUnit] = []
//        var currentContext: BlockContext?
//        var currentString = NSMutableAttributedString()
//
//        func flushCurrentUnit() {
//            guard let currentContext, currentString.length > 0 else { return }
//            units.append(
//                RenderedTextUnit(
//                    attributedString: NSAttributedString(attributedString: currentString),
//                    context: currentContext
//                )
//            )
//            currentString = NSMutableAttributedString()
//        }
//
//        unsafe attributedString.enumerateAttributes(in: fullRange) { attributes, range, _ in
//            let context = blockContext(for: attributes[.markdownPresentationIntent] as? PresentationIntent)
//            let substring = NSMutableAttributedString(
//                attributedString: attributedString.attributedSubstring(from: range)
//            )
//            substring.removeAttribute(.markdownPresentationIntent, range: substring.fullRange)
//            substring.removeAttribute(.markdownListItemDelimiter, range: substring.fullRange)
//
//            if currentContext == context {
//                currentString.append(substring)
//            } else {
//                flushCurrentUnit()
//                currentContext = context
//                currentString = substring
//            }
//        }
//
//        flushCurrentUnit()
//        return units
//    }
//
//    private func blockContext(for presentationIntent: PresentationIntent?) -> BlockContext {
//        let context = presentationContext(for: presentationIntent)
//
//        if let listContext = context.listContext {
//            return BlockContext(
//                kind: .listItem(
//                    .init(
//                        marker: listMarker(for: listContext.marker),
//                        level: listContext.level,
//                        groupIdentity: listContext.groupIdentity
//                    )
//                ),
//                quoteDepth: context.quoteDepth,
//                quoteIdentity: context.quoteIdentity,
//                blockIdentity: context.blockIdentity
//            )
//        }
//
//        let kind: BlockContext.Kind
//        switch context.kind {
//        case .paragraph:
//            kind = .paragraph
//        case .heading(let level):
//            kind = .heading(level)
//        case .thematicBreak:
//            kind = .thematicBreak
//        }
//
//        return BlockContext(
//            kind: kind,
//            quoteDepth: context.quoteDepth,
//            quoteIdentity: context.quoteIdentity,
//            blockIdentity: context.blockIdentity
//        )
//    }
//
//    private func presentationContext(for presentationIntent: PresentationIntent?) -> MarkdownPresentationContext {
//        let components = presentationIntent?.components ?? []
//        let quoteIdentity = components.first { component in
//            if case .blockQuote = component.kind {
//                true
//            } else {
//                false
//            }
//        }?.identity
//        let quoteDepth = components.reduce(into: 0) { count, component in
//            if case .blockQuote = component.kind {
//                count += 1
//            }
//        }
//
//        if let thematicBreak = components.first(where: isThematicBreak) {
//            return MarkdownPresentationContext(
//                kind: .thematicBreak,
//                quoteDepth: quoteDepth,
//                quoteIdentity: quoteIdentity,
//                blockIdentity: thematicBreak.identity,
//                listContext: nil
//            )
//        }
//
//        if let header = components.first(where: isHeader) {
//            guard case let .header(level) = header.kind else {
//                return MarkdownPresentationContext(
//                    kind: .paragraph,
//                    quoteDepth: quoteDepth,
//                    quoteIdentity: quoteIdentity,
//                    blockIdentity: header.identity,
//                    listContext: nil
//                )
//            }
//
//            return MarkdownPresentationContext(
//                kind: .heading(level),
//                quoteDepth: quoteDepth,
//                quoteIdentity: quoteIdentity,
//                blockIdentity: header.identity,
//                listContext: nil
//            )
//        }
//
//        let paragraph = components.first(where: isParagraph)
//        let listItem = components.first(where: isListItem)
//        let list = components.first(where: isList)
//
//        let listContext: MarkdownListContext?
//        if let listItem, let list {
//            let marker: ListMarker
//            switch (list.kind, listItem.kind) {
//            case (.orderedList, .listItem(let ordinal)):
//                marker = .ordered(ordinal)
//            default:
//                marker = .bullet
//            }
//
//            listContext = MarkdownListContext(
//                marker: marker,
//                level: max(presentationIntent?.indentationLevel ?? 1, 1),
//                groupIdentity: list.identity
//            )
//        } else {
//            listContext = nil
//        }
//
//        return MarkdownPresentationContext(
//            kind: .paragraph,
//            quoteDepth: quoteDepth,
//            quoteIdentity: quoteIdentity,
//            blockIdentity: paragraph?.identity ?? components.first?.identity ?? 0,
//            listContext: listContext
//        )
//    }
//
//    private func isParagraph(_ component: PresentationIntent.IntentType) -> Bool {
//        if case .paragraph = component.kind {
//            true
//        } else {
//            false
//        }
//    }
//
//    private func isHeader(_ component: PresentationIntent.IntentType) -> Bool {
//        if case .header = component.kind {
//            true
//        } else {
//            false
//        }
//    }
//
//    private func isList(_ component: PresentationIntent.IntentType) -> Bool {
//        switch component.kind {
//        case .orderedList, .unorderedList:
//            true
//        default:
//            false
//        }
//    }
//
//    private func isListItem(_ component: PresentationIntent.IntentType) -> Bool {
//        if case .listItem = component.kind {
//            true
//        } else {
//            false
//        }
//    }
//
//    private func isThematicBreak(_ component: PresentationIntent.IntentType) -> Bool {
//        if case .thematicBreak = component.kind {
//            true
//        } else {
//            false
//        }
//    }
//
//    private func styledBlock(_ unit: RenderedTextUnit) -> NSAttributedString {
//        switch unit.context.kind {
//        case .listItem:
//            return styledListItem(unit)
//        case .thematicBreak:
//            return thematicBreakAttributedString(quoteDepth: unit.context.quoteDepth)
//        case .paragraph, .heading:
//            let output = NSMutableAttributedString(attributedString: unit.attributedString)
//            normalizeFonts(in: output)
//
//            let paragraphStyle = paragraphStyle(
//                paragraphStyle(),
//                adjustedForQuoteDepth: unit.context.quoteDepth
//            )
//            let foregroundColor = unit.context.quoteDepth > 0 ? quoteTextColor() : NSColor.labelColor
//
//            output.addAttribute(.paragraphStyle, value: paragraphStyle, range: output.fullRange)
//            output.addAttribute(.foregroundColor, value: foregroundColor, range: output.fullRange)
//
//            if case .heading(let level) = unit.context.kind {
//                output.addAttribute(.font, value: headingFont(for: level), range: output.fullRange)
//            }
//
//            applyInlineCodeStyling(to: output)
//            return output
//        }
//    }
//
//    private func styledListItem(_ unit: RenderedTextUnit) -> NSAttributedString {
//        guard case .listItem(let listContext) = unit.context.kind else {
//            return styledBlock(unit)
//        }
//
//        let marker = markerText(for: listContext.marker)
//        let markerIndent = CGFloat(max(0, listContext.level - 1)) * 20
//        let style = paragraphStyle(
//            listParagraphStyle(markerIndent: markerIndent, marker: marker),
//            adjustedForQuoteDepth: unit.context.quoteDepth
//        )
//        let foregroundColor = unit.context.quoteDepth > 0 ? quoteTextColor() : NSColor.labelColor
//
//        let output = NSMutableAttributedString(
//            string: "\(marker)\t",
//            attributes: [
//                .font: bodyFont(),
//                .paragraphStyle: style,
//                .foregroundColor: foregroundColor
//            ]
//        )
//
//        let content = NSMutableAttributedString(attributedString: unit.attributedString)
//        normalizeFonts(in: content)
//        content.addAttribute(.paragraphStyle, value: style, range: content.fullRange)
//        content.addAttribute(.foregroundColor, value: foregroundColor, range: content.fullRange)
//        applyInlineCodeStyling(to: content)
//
//        output.append(content)
//        return output
//    }
//
//    private func thematicBreakAttributedString(quoteDepth: Int) -> NSAttributedString {
//        NSAttributedString(
//            string: String(repeating: "─", count: 18),
//            attributes: [
//                .font: bodyFont(),
//                .foregroundColor: quoteDepth > 0 ? quoteTextColor() : separatorColor(),
//                .paragraphStyle: paragraphStyle(
//                    centeredParagraphStyle(),
//                    adjustedForQuoteDepth: quoteDepth
//                )
//            ]
//        )
//    }
//
//    private func listMarker(for marker: ListMarker) -> BlockContext.ListContext.Marker {
//        switch marker {
//        case .bullet:
//            return .bullet
//        case .ordered(let value):
//            return .ordered(value)
//        }
//    }
//
//    private func normalizeFonts(in attributedString: NSMutableAttributedString) {
//        let fullRange = attributedString.fullRange
//
//        if fullRange.length == 0 {
//            return
//        }
//
//        unsafe attributedString.enumerateAttribute(.font, in: fullRange) { value, range, _ in
//            guard let font = value as? NSFont else {
//                attributedString.addAttribute(.font, value: bodyFont(), range: range)
//                return
//            }
//
//            let traits = font.fontDescriptor.symbolicTraits
//            let weight: NSFont.Weight
//            if traits.contains(.bold) {
//                weight = .semibold
//            } else {
//                weight = .regular
//            }
//
//            let normalizedFont: NSFont
//            if font.fontDescriptor.symbolicTraits.contains(.monoSpace) {
//                normalizedFont = .monospacedSystemFont(ofSize: codeFontSize, weight: weight)
//            } else {
//                normalizedFont = .systemFont(ofSize: bodyFontSize, weight: weight)
//            }
//
//            attributedString.addAttribute(.font, value: normalizedFont, range: range)
//        }
//    }
//
//    private func applyInlineCodeStyling(to attributedString: NSMutableAttributedString) {
//        let fullRange = attributedString.fullRange
//        guard fullRange.length > 0 else { return }
//
//        unsafe attributedString.enumerateAttribute(.markdownInlinePresentationIntent, in: fullRange) { value, range, _ in
//            let isInlineCode: Bool
//            if let intent = value as? InlinePresentationIntent {
//                isInlineCode = intent.contains(.code)
//            } else {
//                let rawValue = (value as? NSNumber)?.intValue ?? 0
//                isInlineCode = rawValue & 4 != 0
//            }
//
//            guard isInlineCode else {
//                return
//            }
//
//            attributedString.addAttributes([
//                .font: NSFont.monospacedSystemFont(ofSize: bodyFontSize, weight: .regular),
//                .foregroundColor: NSColor.controlAccentColor
//            ], range: range)
//        }
//    }
//
//    private func codeBlockParagraphStyle() -> NSParagraphStyle {
//        let style = NSMutableParagraphStyle()
//        style.lineSpacing = 3
//        style.firstLineHeadIndent = 14
//        style.headIndent = 14
//        style.tailIndent = -14
//        style.lineBreakMode = .byCharWrapping
//        return style
//    }
//
//    private func renderedQuoteBlocks(
//        from markdown: String,
//        in attributedString: NSAttributedString,
//        at location: Int
//    ) -> [MarkdownQuoteBlock] {
//        guard !markdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            return []
//        }
//
//        let parsed: NSMutableAttributedString
//        if let attributed = try? NSAttributedString(
//            markdown: markdown,
//            options: .init(
//                allowsExtendedAttributes: true,
//                interpretedSyntax: .full,
//                failurePolicy: .returnPartiallyParsedIfPossible
//            ),
//            baseURL: nil
//        ) {
//            parsed = NSMutableAttributedString(attributedString: attributed)
//        } else {
//            parsed = NSMutableAttributedString(string: markdown)
//        }
//
//        let units = renderedTextUnits(from: parsed)
//        guard !units.isEmpty else { return [] }
//
//        var quoteBlocks: [MarkdownQuoteBlock] = []
//        var renderedLocation = location
//        var index = 0
//
//        while index < units.count {
//            let unit = units[index]
//            let hasLeadingSpacing = renderedLocation > location
//            let segmentStart = renderedLocation + (hasLeadingSpacing ? 2 : 0)
//            let segmentLength: Int
//
//            switch unit.context.kind {
//            case .listItem(let listContext):
//                var length = 0
//                var isFirstItem = true
//
//                while index < units.count {
//                    guard case .listItem(let candidateContext) = units[index].context.kind,
//                          candidateContext.groupIdentity == listContext.groupIdentity else {
//                        break
//                    }
//
//                    if !isFirstItem {
//                        length += 1
//                    }
//
//                    length += styledListItem(units[index]).length
//                    isFirstItem = false
//                    index += 1
//                }
//
//                segmentLength = length
//
//            default:
//                segmentLength = styledBlock(unit).length
//                index += 1
//            }
//
//            if unit.context.quoteDepth > 0, segmentLength > 0 {
//                let maxLength = max(0, (location + attributedString.length) - segmentStart)
//                let clampedLength = min(segmentLength, maxLength)
//
//                if clampedLength > 0 {
//                    quoteBlocks.append(
//                        MarkdownQuoteBlock(
//                            range: NSRange(location: segmentStart, length: clampedLength),
//                            depth: unit.context.quoteDepth,
//                            identity: unit.context.quoteIdentity ?? unit.context.blockIdentity
//                        )
//                    )
//                }
//            }
//
//            renderedLocation = segmentStart + segmentLength
//        }
//
//        return quoteBlocks
//    }
//
//    private func mergeQuoteBlocks(_ quoteBlocks: inout [MarkdownQuoteBlock], with newBlocks: [MarkdownQuoteBlock]) {
//        for block in newBlocks {
//            guard let lastBlock = quoteBlocks.last else {
//                quoteBlocks.append(block)
//                continue
//            }
//
//            let lastBlockEnd = lastBlock.range.location + lastBlock.range.length
//            let gapLength = block.range.location - lastBlockEnd
//
//            if lastBlock.identity == block.identity,
//               lastBlock.depth == block.depth,
//               gapLength >= 0,
//               gapLength <= 2 {
//                quoteBlocks[quoteBlocks.count - 1] = MarkdownQuoteBlock(
//                    range: NSRange(
//                        location: lastBlock.range.location,
//                        length: (block.range.location + block.range.length) - lastBlock.range.location
//                    ),
//                    depth: block.depth,
//                    identity: block.identity
//                )
//            } else {
//                quoteBlocks.append(block)
//            }
//        }
//    }
//
//    private func markerText(for marker: BlockContext.ListContext.Marker) -> String {
//        switch marker {
//        case .bullet:
//            "•"
//        case .ordered(let value):
//            "\(value)."
//        }
//    }
//
//    private func paragraphStyle() -> NSParagraphStyle {
//        let style = NSMutableParagraphStyle()
//        style.lineSpacing = 4
//        style.paragraphSpacing = 0
//        return style
//    }
//
//    private func centeredParagraphStyle() -> NSParagraphStyle {
//        let style = NSMutableParagraphStyle()
//        style.alignment = .center
//        return style
//    }
//
//    private func separatorColor() -> NSColor {
//        NSColor.labelColor.withAlphaComponent(0.3)
//    }
//
//    private func quoteTextColor() -> NSColor {
//        NSColor.secondaryLabelColor
//    }
//
//    private func listParagraphStyle(markerIndent: CGFloat, marker: String, font: NSFont? = nil) -> NSParagraphStyle {
//        let style = NSMutableParagraphStyle()
//        let markerFont = font ?? bodyFont()
//        let markerWidth = marker.size(withAttributes: [.font: markerFont]).width
//        let contentIndent = markerIndent + markerWidth + 10
//        style.firstLineHeadIndent = markerIndent
//        style.headIndent = contentIndent
//        style.tabStops = [NSTextTab(textAlignment: .left, location: contentIndent)]
//        style.defaultTabInterval = contentIndent
//        style.lineSpacing = 4
//        return style
//    }
//
//    private func paragraphStyle(
//        _ baseStyle: NSParagraphStyle,
//        adjustedForQuoteDepth quoteDepth: Int
//    ) -> NSParagraphStyle {
//        guard quoteDepth > 0 else { return baseStyle }
//
//        let style = baseStyle.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
//        let quoteIndent = CGFloat(quoteDepth) * 16
//        style.headIndent += quoteIndent
//        style.firstLineHeadIndent += quoteIndent
//        style.paragraphSpacing = max(style.paragraphSpacing, 4)
//        style.paragraphSpacingBefore = max(style.paragraphSpacingBefore, 2)
//        return style
//    }
//
//    private func headingFont(for level: Int) -> NSFont {
//        switch level {
//        case 1: return .systemFont(ofSize: bodyFontSize + 11, weight: .bold)
//        case 2: return .systemFont(ofSize: bodyFontSize + 6, weight: .bold)
//        case 3: return .systemFont(ofSize: bodyFontSize + 3, weight: .semibold)
//        case 4: return .systemFont(ofSize: bodyFontSize, weight: .semibold)
//        default: return .systemFont(ofSize: bodyFontSize, weight: .regular)
//        }
//    }
//
//    private func bodyFont() -> NSFont {
//        .systemFont(ofSize: bodyFontSize, weight: .regular)
//    }
//}
//
//private extension NSAttributedString {
//    var fullRange: NSRange {
//        NSRange(location: 0, length: length)
//    }
//}
//
//private extension NSAttributedString.Key {
//    static let markdownInlinePresentationIntent = Self("NSInlinePresentationIntent")
//    static let markdownListItemDelimiter = Self("NSListItemDelimiter")
//    static let markdownPresentationIntent = Self("NSPresentationIntent")
//    static let markdownCodeBlockID = Self("LynkChatMarkdownCodeBlockID")
//}
//#endif
