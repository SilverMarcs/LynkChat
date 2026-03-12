import SwiftUI

#if os(macOS)
import AppKit
import Highlightr

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

private struct MarkdownRenderCache {
    let text: String
    let fontSize: CGFloat
    let blocks: [MarkdownRenderedBlock]
}

private struct MacMarkdownRepresentable: NSViewRepresentable {
    let text: String
    let fontSize: CGFloat
    var calculatedHeight: Binding<CGFloat>?

    final class Coordinator {
        private var cachedRender: MarkdownRenderCache?

        func blocks(for text: String, fontSize: CGFloat) -> [MarkdownRenderedBlock] {
            if let cachedRender, cachedRender.text == text, cachedRender.fontSize == fontSize {
                return cachedRender.blocks
            }

            let blocks = MacMarkdownRenderer(fontSize: fontSize).render(text)
            cachedRender = MarkdownRenderCache(text: text, fontSize: fontSize, blocks: blocks)
            return blocks
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> MarkdownContainerView {
        MarkdownContainerView()
    }

    func updateNSView(_ nsView: MarkdownContainerView, context: Context) {
        let blocks = context.coordinator.blocks(for: text, fontSize: fontSize)
        nsView.onHeightChange = { newHeight in
            guard let calculatedHeight, calculatedHeight.wrappedValue != newHeight else { return }
            calculatedHeight.wrappedValue = newHeight
        }
        nsView.update(blocks: blocks)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: MarkdownContainerView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        nsView.update(blocks: context.coordinator.blocks(for: text, fontSize: fontSize))
        return nsView.measuredSize(for: width)
    }
}

private final class MarkdownContainerView: NSView {
    private let stackView = NSStackView()
    private var currentWidth: CGFloat = 0
    private var lastReportedHeight: CGFloat = 0
    private var lastMeasuredSize: CGSize = .zero
    var onHeightChange: ((CGFloat) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false

        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(blocks: [MarkdownRenderedBlock]) {
        let existingViews = stackView.arrangedSubviews
        if existingViews.count > blocks.count {
            for view in existingViews.suffix(existingViews.count - blocks.count) {
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }

        for (index, block) in blocks.enumerated() {
            let view: NSView
            if index < stackView.arrangedSubviews.count {
                view = stackView.arrangedSubviews[index]
                configure(view: view, with: block)
            } else {
                view = makeView(for: block)
                stackView.addArrangedSubview(view)
            }
        }

        needsLayout = true
        invalidateIntrinsicContentSize()

        if currentWidth > 0 {
            applyPreferredWidth(currentWidth)
            let measuredHeight = measureHeight()
            lastMeasuredSize = CGSize(width: currentWidth, height: measuredHeight)
            reportHeightIfNeeded(measuredHeight)
        }
    }

    func measuredSize(for width: CGFloat) -> CGSize {
        currentWidth = width
        applyPreferredWidth(width)
        let measuredHeight = measureHeight()
        let measuredSize = CGSize(width: width, height: measuredHeight)
        lastMeasuredSize = measuredSize
        return measuredSize
    }

    override func layout() {
        super.layout()

        let width = bounds.width > 0 ? bounds.width : currentWidth
        guard width > 0 else { return }

        currentWidth = width
        applyPreferredWidth(width)
        let measuredHeight = measureHeight()
        lastMeasuredSize = CGSize(width: width, height: measuredHeight)
        reportHeightIfNeeded(measuredHeight)
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: lastMeasuredSize.width, height: lastMeasuredSize.height)
    }

    private func applyPreferredWidth(_ width: CGFloat) {
        for case let measurable as MarkdownMeasurable in stackView.arrangedSubviews {
            measurable.update(preferredWidth: width)
        }
    }

    private func measureHeight() -> CGFloat {
        let fittingHeight = stackView.arrangedSubviews.reduce(CGFloat.zero) { partial, view in
            partial + view.fittingSize.height
        } + CGFloat(max(0, stackView.arrangedSubviews.count - 1)) * stackView.spacing

        return ceil(fittingHeight)
    }

    private func reportHeightIfNeeded(_ measuredHeight: CGFloat) {
        guard measuredHeight > 0, measuredHeight != lastReportedHeight else { return }

        lastReportedHeight = measuredHeight
        Task { @MainActor in
            self.onHeightChange?(measuredHeight)
        }
    }

    private func makeView(for block: MarkdownRenderedBlock) -> NSView {
        switch block {
        case .text(let attributedStrings):
            return MarkdownTextBlockView(attributedStrings: attributedStrings)
        case .code(let content, let language, let fontSize):
            return MarkdownCodeBlockView(content: content, language: language, codeFontSize: fontSize)
        }
    }

    private func configure(view: NSView, with block: MarkdownRenderedBlock) {
        switch (view, block) {
        case let (textView as MarkdownTextBlockView, .text(attributedStrings)):
            textView.update(attributedStrings: attributedStrings)
        case let (codeView as MarkdownCodeBlockView, .code(content, language, fontSize)):
            codeView.update(content: content, language: language, codeFontSize: fontSize)
        default:
            if let index = stackView.arrangedSubviews.firstIndex(of: view) {
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
                let replacement = makeView(for: block)
                stackView.insertArrangedSubview(replacement, at: index)
            }
        }
    }
}

private protocol MarkdownMeasurable {
    func update(preferredWidth: CGFloat)
}

private func markdownAncestorMenu(from view: NSView) -> NSMenu? {
    var currentView = unsafe view.superview

    while let candidate = currentView {
        if let menu = candidate.menu {
            return menu
        }

        currentView = unsafe candidate.superview
    }

    return nil
}

private final class MarkdownPlainTextView: NSTextView {
    let markdownTextStorage = NSTextStorage()
    let markdownLayoutManager = NSLayoutManager()
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
}

private final class MarkdownCodeTextView: NSTextView {
    let markdownTextStorage = NSTextStorage()
    let markdownLayoutManager = NSLayoutManager()
    let markdownTextContainer = NSTextContainer()
    private(set) var codeFont = MarkdownCodeTextView.makeCodeFont(size: NSFont.preferredFont(forTextStyle: .body).pointSize)

    init() {
        markdownLayoutManager.addTextContainer(markdownTextContainer)
        markdownTextStorage.addLayoutManager(markdownLayoutManager)
        super.init(frame: .zero, textContainer: markdownTextContainer)
        font = codeFont
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        markdownAncestorMenu(from: self)
    }

    func setCodeFontSize(_ size: CGFloat) {
        let resolvedFont = Self.makeCodeFont(size: size)
        guard resolvedFont != codeFont else { return }
        codeFont = resolvedFont
        font = resolvedFont
    }

    private static func makeCodeFont(size: CGFloat) -> NSFont {
        .monospacedSystemFont(ofSize: size, weight: .regular)
    }
}

private final class MarkdownHorizontalScrollView: NSScrollView {
    override func scrollWheel(with event: NSEvent) {
        let horizontalDelta = abs(event.scrollingDeltaX)
        let verticalDelta = abs(event.scrollingDeltaY)

        guard horizontalDelta > verticalDelta else {
            ancestorScrollView?.scrollWheel(with: event)
            return
        }

        super.scrollWheel(with: event)
    }

    private var ancestorScrollView: NSScrollView? {
        var currentView = unsafe superview

        while let view = currentView {
            if let scrollView = view as? NSScrollView {
                return scrollView
            }

            currentView = unsafe view.superview
        }

        return nil
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        markdownAncestorMenu(from: self)
    }
}

private final class MarkdownBackgroundView: NSView {
    override func menu(for event: NSEvent) -> NSMenu? {
        markdownAncestorMenu(from: self)
    }
}

private final class MarkdownTextBlockView: NSView, MarkdownMeasurable {
    private let textView = MarkdownPlainTextView()
    private var widthConstraint: NSLayoutConstraint?
    private var preferredWidth: CGFloat = 0
    private var currentAttributedStrings: [NSAttributedString] = []
    private var currentMeasuredSize: NSSize = .zero

    init(attributedStrings: [NSAttributedString]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        textView.drawsBackground = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRichText = true
        textView.importsGraphics = false
        textView.textContainerInset = .zero
        textView.markdownTextContainer.lineFragmentPadding = 0
        textView.markdownTextContainer.widthTracksTextView = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(textView)

        let widthConstraint = textView.widthAnchor.constraint(equalToConstant: 0)
        self.widthConstraint = widthConstraint

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint
        ])

        update(attributedStrings: attributedStrings)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(attributedStrings: [NSAttributedString]) {
        guard !markdownAttributedStringsEqual(currentAttributedStrings, attributedStrings) else { return }

        currentAttributedStrings = attributedStrings
        let combinedString = NSMutableAttributedString()

        for (index, attributedString) in attributedStrings.enumerated() {
            if index > 0 {
                combinedString.append(NSAttributedString(string: "\n\n"))
            }
            combinedString.append(attributedString)
        }

        textView.markdownTextStorage.setAttributedString(combinedString)
        if preferredWidth > 0 {
            refreshMeasuredSize(for: preferredWidth)
        }
        invalidateIntrinsicContentSize()
    }

    func update(preferredWidth: CGFloat) {
        guard preferredWidth > 0 else { return }
        let resolvedWidth = ceil(preferredWidth)
        guard resolvedWidth != self.preferredWidth else { return }

        self.preferredWidth = resolvedWidth
        widthConstraint?.constant = resolvedWidth
        refreshMeasuredSize(for: resolvedWidth)
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: NSSize {
        currentMeasuredSize
    }

    override var fittingSize: NSSize {
        currentMeasuredSize
    }

    private func refreshMeasuredSize(for width: CGFloat) {
        guard width > 0 else {
            currentMeasuredSize = .zero
            return
        }

        textView.frame.size.width = width
        textView.markdownTextContainer.containerSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        textView.markdownLayoutManager.ensureLayout(for: textView.markdownTextContainer)
        let usedRect = textView.markdownLayoutManager.usedRect(for: textView.markdownTextContainer)
        currentMeasuredSize = NSSize(width: width, height: ceil(usedRect.height))
    }
}

private final class MarkdownCodeBlockView: NSView, MarkdownMeasurable {
    private enum Layout {
        static let contentPadding: CGFloat = 14
        static let buttonInset: CGFloat = 10
        static let buttonSize: CGFloat = 28
        static let minimumContentWidth: CGFloat = 160
    }

    private let backgroundView = MarkdownBackgroundView()
    private let scrollView = MarkdownHorizontalScrollView()
    private let textView = MarkdownCodeTextView()
    private let copyButton = NSButton()
    private let syntaxHighlighter = Highlightr()
    private var widthConstraint: NSLayoutConstraint?
    private var content: String
    private var language: String?
    private var codeFontSize: CGFloat
    private var preferredWidth: CGFloat = 0
    private var currentThemeName: String?
    private var currentMeasuredSize: NSSize = .zero
    private var renderedContentHeight: CGFloat = 0

    init(content: String, language: String?, codeFontSize: CGFloat) {
        self.content = content
        self.language = language
        self.codeFontSize = codeFontSize
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        wantsLayer = true

        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = 12
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        copyButton.image = NSImage(
            systemSymbolName: "clipboard",
            accessibilityDescription: "Copy code"
        )
        copyButton.imagePosition = .imageOnly
        copyButton.bezelStyle = .regularSquare
        copyButton.controlSize = .small
        copyButton.target = self
        copyButton.action = #selector(copyCode)
        copyButton.wantsLayer = true
        copyButton.layer?.cornerRadius = 8
        copyButton.translatesAutoresizingMaskIntoConstraints = false

        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.verticalScrollElasticity = .none
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        textView.drawsBackground = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRichText = false
        textView.importsGraphics = false
        textView.textContainerInset = NSSize(width: 0, height: 0)
        textView.markdownTextContainer.lineFragmentPadding = 0
        textView.markdownTextContainer.widthTracksTextView = false
        textView.markdownTextContainer.heightTracksTextView = false
        textView.isHorizontallyResizable = true
        textView.isVerticallyResizable = false
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = .zero
        textView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = textView

        addSubview(backgroundView)
        backgroundView.addSubview(copyButton)
        backgroundView.addSubview(scrollView)

        let widthConstraint = backgroundView.widthAnchor.constraint(equalToConstant: 0)
        self.widthConstraint = widthConstraint

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint,

            scrollView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: Layout.contentPadding),
            scrollView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -Layout.contentPadding),
            scrollView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: Layout.contentPadding),
            scrollView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -Layout.contentPadding),

            copyButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -Layout.buttonInset),
            copyButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -Layout.buttonInset),
            copyButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize),
            copyButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize)
        ])

        update(content: content, language: language, codeFontSize: codeFontSize)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        update(content: content, language: language, codeFontSize: codeFontSize)
    }

    func update(content: String, language: String?, codeFontSize: CGFloat? = nil) {
        let resolvedCodeFontSize = codeFontSize ?? self.codeFontSize
        let themeName = colorSchemeThemeName
        let needsContentRefresh = content != self.content
            || language != self.language
            || resolvedCodeFontSize != self.codeFontSize
            || themeName != currentThemeName

        self.content = content
        self.language = language
        self.codeFontSize = resolvedCodeFontSize
        updateAppearance(themeName: themeName)

        guard needsContentRefresh else { return }

        textView.setCodeFontSize(self.codeFontSize)
        textView.markdownTextStorage.setAttributedString(attributedCode())
        updateTextViewFrame()
        refreshMeasuredSize(for: preferredWidth)
        invalidateIntrinsicContentSize()
    }

    func update(preferredWidth: CGFloat) {
        guard preferredWidth > 0 else { return }
        let resolvedWidth = ceil(preferredWidth)
        guard resolvedWidth != self.preferredWidth else { return }

        self.preferredWidth = resolvedWidth
        widthConstraint?.constant = resolvedWidth
        refreshMeasuredSize(for: resolvedWidth)
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: NSSize {
        currentMeasuredSize
    }

    override var fittingSize: NSSize {
        currentMeasuredSize
    }

    private func attributedCode() -> NSAttributedString {
        let codeFont = textView.codeFont
        if let highlighted = syntaxHighlighter?.highlight(content, as: language) {
            let output = NSMutableAttributedString(attributedString: highlighted)
            output.addAttribute(.font, value: codeFont, range: output.fullRange)
            return output
        }

        return NSAttributedString(
            string: content,
            attributes: [
                .font: codeFont,
                .foregroundColor: NSColor.labelColor
            ]
        )
    }

    private func updateAppearance(themeName: String) {
        if currentThemeName != themeName {
            syntaxHighlighter?.setTheme(to: themeName)
            currentThemeName = themeName
        }
        backgroundView.layer?.backgroundColor = codeBlockBackgroundColor.cgColor
        copyButton.contentTintColor = .labelColor
        copyButton.layer?.backgroundColor = .clear
    }

    private var colorSchemeThemeName: String {
        switch effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
        case .darkAqua:
            "atom-one-dark"
        default:
            "atom-one-light"
        }
    }

    private var codeBlockBackgroundColor: NSColor {
        let windowColor = NSColor.windowBackgroundColor.usingColorSpace(.deviceRGB) ?? .windowBackgroundColor
        let shadowColor = NSColor.black.withAlphaComponent(0.28).usingColorSpace(.deviceRGB) ?? .black
        let lightModeShadow = NSColor.labelColor.withAlphaComponent(0.08).usingColorSpace(.deviceRGB) ?? .labelColor

        switch effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
        case .darkAqua:
            return windowColor.blended(withFraction: 0.14, of: shadowColor) ?? windowColor
        default:
            return windowColor.blended(withFraction: 0.06, of: lightModeShadow) ?? windowColor
        }
    }

    private func updateTextViewFrame() {
        textView.markdownTextContainer.containerSize = CGSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.markdownLayoutManager.ensureLayout(for: textView.markdownTextContainer)

        let usedRect = textView.markdownLayoutManager.usedRect(for: textView.markdownTextContainer)
        let fittedSize = NSSize(
            width: ceil(max(Layout.minimumContentWidth, usedRect.width)),
            height: ceil(usedRect.height)
        )

        renderedContentHeight = fittedSize.height
        textView.setFrameSize(fittedSize)
    }

    private func refreshMeasuredSize(for width: CGFloat) {
        guard width > 0 else {
            currentMeasuredSize = .zero
            return
        }
        let totalHeight = (Layout.contentPadding * 2) + renderedContentHeight
        currentMeasuredSize = NSSize(width: width, height: totalHeight)
    }

    @objc
    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
    }
}

private enum MarkdownRenderedBlock {
    case text([NSAttributedString])
    case code(String, language: String?, fontSize: CGFloat)
}

private func markdownAttributedStringsEqual(_ lhs: [NSAttributedString], _ rhs: [NSAttributedString]) -> Bool {
    guard lhs.count == rhs.count else { return false }

    for (left, right) in zip(lhs, rhs) {
        guard left.isEqual(right) else { return false }
    }

    return true
}

private struct MacMarkdownRenderer {
    private enum Block {
        case paragraph(String)
        case heading(level: Int, text: String)
        case list(items: [Item])
        case quote([Block])
        case codeBlock(String, language: String?)
        case thematicBreak
    }

    private struct Item {
        enum Marker {
            case bullet
            case ordered(Int)
        }

        let marker: Marker
        let content: String
        let level: Int
    }

    private let fontSize: CGFloat
    private let bodyFontSize: CGFloat
    private let codeFontSize: CGFloat

    init(fontSize: CGFloat) {
        self.fontSize = fontSize
        self.bodyFontSize = max(fontSize, 13)
        self.codeFontSize = max(self.bodyFontSize - 1, 12)
    }

    func render(_ markdown: String) -> [MarkdownRenderedBlock] {
        renderBlocks(parseBlocks(markdown), quoteDepth: 0)
    }

    private func renderBlocks(_ blocks: [Block], quoteDepth: Int) -> [MarkdownRenderedBlock] {
        var renderedBlocks: [MarkdownRenderedBlock] = []
        var pendingTextBlocks: [NSAttributedString] = []

        func flushPendingTextBlocks() {
            guard !pendingTextBlocks.isEmpty else { return }
            renderedBlocks.append(.text(pendingTextBlocks))
            pendingTextBlocks.removeAll(keepingCapacity: true)
        }

        for block in blocks {
            switch block {
            case .codeBlock(let code, let language):
                flushPendingTextBlocks()
                renderedBlocks.append(.code(code, language: language, fontSize: codeFontSize))
            case .quote(let nestedBlocks):
                for renderedQuoteBlock in renderBlocks(nestedBlocks, quoteDepth: quoteDepth + 1) {
                    switch renderedQuoteBlock {
                    case .text(let attributedStrings):
                        pendingTextBlocks.append(contentsOf: attributedStrings)
                    case .code:
                        flushPendingTextBlocks()
                        renderedBlocks.append(renderedQuoteBlock)
                    }
                }
            default:
                pendingTextBlocks.append(attributedBlock(for: block, quoteDepth: quoteDepth))
            }
        }

        flushPendingTextBlocks()
        return renderedBlocks
    }

    private func parseBlocks(_ markdown: String) -> [Block] {
        let lines = markdown.components(separatedBy: .newlines)
        var blocks: [Block] = []
        var index = 0

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                index += 1
                continue
            }

            if trimmed.hasPrefix("```") {
                let language = parseCodeBlockLanguage(from: trimmed)
                var codeLines: [String] = []
                index += 1
                while index < lines.count, lines[index].trimmingCharacters(in: .whitespaces) != "```" {
                    codeLines.append(lines[index])
                    index += 1
                }
                index += 1
                blocks.append(.codeBlock(codeLines.joined(separator: "\n"), language: language))
                continue
            }

            if isThematicBreak(trimmed) {
                blocks.append(.thematicBreak)
                index += 1
                continue
            }

            if let heading = parseHeading(line: line) {
                blocks.append(.heading(level: heading.level, text: heading.text))
                index += 1
                continue
            }

            if isQuoteLine(line) {
                let (quote, nextIndex) = parseQuote(from: index, lines: lines)
                blocks.append(.quote(quote))
                index = nextIndex
                continue
            }

            if isListLine(line) {
                let (items, nextIndex) = parseList(from: index, lines: lines)
                blocks.append(.list(items: items))
                index = nextIndex
                continue
            }

            var paragraphLines: [String] = []
            while index < lines.count {
                let currentLine = lines[index]
                let currentTrimmed = currentLine.trimmingCharacters(in: .whitespaces)
                if currentTrimmed.isEmpty
                    || currentTrimmed.hasPrefix("```")
                    || isThematicBreak(currentTrimmed)
                    || parseHeading(line: currentLine) != nil
                    || isQuoteLine(currentLine)
                    || isListLine(currentLine)
                {
                    break
                }
                paragraphLines.append(currentLine)
                index += 1
            }

            if !paragraphLines.isEmpty {
                blocks.append(.paragraph(paragraphLines.joined(separator: "\n")))
            } else {
                index += 1
            }
        }

        return blocks
    }

    private func parseCodeBlockLanguage(from trimmedFenceLine: String) -> String? {
        let languageHint = trimmedFenceLine
            .dropFirst(3)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !languageHint.isEmpty else {
            return nil
        }

        return languageHint
            .split(whereSeparator: \.isWhitespace)
            .first
            .map(String.init)
    }

    private func attributedBlock(for block: Block, quoteDepth: Int) -> NSAttributedString {
        switch block {
        case .paragraph(let text):
            return attributedMarkdown(
                text,
                paragraphStyle: paragraphStyle(),
                quoteDepth: quoteDepth
            )
        case .heading(let level, let text):
            return attributedHeading(level: level, text: text, quoteDepth: quoteDepth)
        case .list(let items):
            return attributedList(items, quoteDepth: quoteDepth)
        case .quote:
            return NSAttributedString(string: "")
        case .codeBlock:
            return NSAttributedString(string: "")
        case .thematicBreak:
            return NSAttributedString(
                string: String(repeating: "─", count: 18),
                attributes: [
                    .font: bodyFont(),
                    .foregroundColor: quoteDepth > 0 ? quoteTextColor() : separatorColor(),
                    .paragraphStyle: paragraphStyle(
                        centeredParagraphStyle(),
                        adjustedForQuoteDepth: quoteDepth
                    )
                ]
            )
        }
    }

    private func attributedList(_ items: [Item], quoteDepth: Int) -> NSAttributedString {
        let output = NSMutableAttributedString()

        for (index, item) in items.enumerated() {
            if index > 0 {
                output.append(NSAttributedString(string: "\n"))
            }

            let marker = markerText(for: item.marker)
            let markerIndent = CGFloat(max(0, item.level - 1)) * 20
            let style = paragraphStyle(
                listParagraphStyle(markerIndent: markerIndent, marker: marker),
                adjustedForQuoteDepth: quoteDepth
            )

            let prefix = NSAttributedString(
                string: "\(marker)\t",
                attributes: [
                    .font: bodyFont(),
                    .paragraphStyle: style,
                    .foregroundColor: quoteDepth > 0 ? quoteTextColor() : NSColor.labelColor
                ]
            )

            let content = NSMutableAttributedString(
                attributedString: attributedMarkdown(
                    item.content,
                    paragraphStyle: style,
                    quoteDepth: quoteDepth
                )
            )
            content.addAttribute(.paragraphStyle, value: style, range: content.fullRange)

            output.append(prefix)
            output.append(content)
        }

        return output
    }

    private func attributedHeading(level: Int, text: String, quoteDepth: Int) -> NSAttributedString {
        let font = headingFont(for: level)

        guard let markerDetails = headingMarkerDetails(from: text, font: font) else {
            let heading = NSMutableAttributedString(
                attributedString: attributedMarkdown(
                    text,
                    paragraphStyle: paragraphStyle(),
                    quoteDepth: quoteDepth
                )
            )
            heading.addAttribute(.font, value: font, range: heading.fullRange)
            return heading
        }

        let output = NSMutableAttributedString(
            string: "\(markerDetails.marker)\t",
            attributes: [
                .font: font,
                .paragraphStyle: paragraphStyle(
                    markerDetails.style,
                    adjustedForQuoteDepth: quoteDepth
                ),
                .foregroundColor: quoteDepth > 0 ? quoteTextColor() : NSColor.labelColor
            ]
        )

        let style = paragraphStyle(markerDetails.style, adjustedForQuoteDepth: quoteDepth)
        let headingContent = NSMutableAttributedString(
            attributedString: attributedMarkdown(
                markerDetails.content,
                paragraphStyle: style,
                quoteDepth: quoteDepth
            )
        )
        headingContent.addAttribute(.font, value: font, range: headingContent.fullRange)
        headingContent.addAttribute(.paragraphStyle, value: style, range: headingContent.fullRange)
        output.append(headingContent)
        return output
    }

    private func attributedMarkdown(
        _ markdown: String,
        paragraphStyle: NSParagraphStyle,
        quoteDepth: Int
    ) -> NSAttributedString {
        let parsed: NSMutableAttributedString

        if let attributed = try? NSAttributedString(
            markdown: markdown,
            options: .init(
                allowsExtendedAttributes: true,
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            ),
            baseURL: nil
        ) {
            parsed = NSMutableAttributedString(attributedString: attributed)
        } else {
            parsed = NSMutableAttributedString(string: markdown)
        }

        normalizeFonts(in: parsed)
        parsed.addAttribute(.paragraphStyle, value: paragraphStyle, range: parsed.fullRange)
        parsed.addAttribute(
            .foregroundColor,
            value: quoteDepth > 0 ? quoteTextColor() : NSColor.labelColor,
            range: parsed.fullRange
        )
        applyInlineCodeStyling(to: parsed)
        return parsed
    }

    private func normalizeFonts(in attributedString: NSMutableAttributedString) {
        let fullRange = attributedString.fullRange

        if fullRange.length == 0 {
            return
        }

        attributedString.enumerateAttribute(.font, in: fullRange) { value, range, _ in
            guard let font = value as? NSFont else {
                attributedString.addAttribute(.font, value: bodyFont(), range: range)
                return
            }

            let traits = font.fontDescriptor.symbolicTraits
            let weight: NSFont.Weight
            if traits.contains(.bold) {
                weight = .semibold
            } else {
                weight = .regular
            }

            let normalizedFont: NSFont
            if font.fontDescriptor.symbolicTraits.contains(.monoSpace) {
                normalizedFont = .monospacedSystemFont(ofSize: codeFontSize, weight: weight)
            } else {
                normalizedFont = .systemFont(ofSize: bodyFontSize, weight: weight)
            }

            attributedString.addAttribute(.font, value: normalizedFont, range: range)
        }
    }

    private func applyInlineCodeStyling(to attributedString: NSMutableAttributedString) {
        let fullRange = attributedString.fullRange
        guard fullRange.length > 0 else { return }

        attributedString.enumerateAttribute(.inlinePresentationIntent, in: fullRange) { value, range, _ in
            let rawValue = (value as? NSNumber)?.intValue ?? 0
            guard rawValue & 4 != 0
            else {
                return
            }

            attributedString.addAttributes([
                .font: NSFont.monospacedSystemFont(ofSize: bodyFontSize, weight: .regular),
                .foregroundColor: NSColor.controlAccentColor
            ], range: range)
        }
    }

    private func parseHeading(line: String) -> (level: Int, text: String)? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.first == "#" else { return nil }
        let hashes = trimmed.prefix { $0 == "#" }
        guard (1...6).contains(hashes.count) else { return nil }
        let remainder = trimmed.dropFirst(hashes.count)
        guard remainder.first == " " else { return nil }
        return (hashes.count, String(remainder.dropFirst()).trimmingCharacters(in: .whitespaces))
    }

    private func isListLine(_ line: String) -> Bool {
        line.range(of: #"^\s*(?:[-*+]\s+|\d+\.\s+)"#, options: .regularExpression) != nil
    }

    private func isQuoteLine(_ line: String) -> Bool {
        line.range(of: #"^\s*>\s?"#, options: .regularExpression) != nil
    }

    private func parseQuote(from startIndex: Int, lines: [String]) -> ([Block], Int) {
        var index = startIndex
        var quoteLines: [String] = []

        while index < lines.count, isQuoteLine(lines[index]) {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let content = String(trimmed.drop(while: { $0 == ">" || $0 == " " }))
            quoteLines.append(content)
            index += 1
        }

        return (parseBlocks(quoteLines.joined(separator: "\n")), index)
    }

    private func parseList(from startIndex: Int, lines: [String]) -> ([Item], Int) {
        var items: [Item] = []
        var index = startIndex

        while index < lines.count {
            let line = lines[index]
            if line.trimmingCharacters(in: .whitespaces).isEmpty { break }
            guard let item = parseListItem(line) else { break }
            items.append(item)
            index += 1
        }

        return (items, index)
    }

    private func parseListItem(_ line: String) -> Item? {
        let spaces = leadingIndent(in: line)
        let level = max(1, spaces / 2 + 1)
        let trimmed = String(line.dropFirst(spaces))

        if let range = trimmed.range(of: #"^\d+\.\s+"#, options: .regularExpression) {
            let markerText = String(trimmed[range]).trimmingCharacters(in: .whitespaces)
            let number = Int(markerText.dropLast()) ?? 1
            let content = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            return Item(marker: .ordered(number), content: content, level: level)
        }

        if let range = trimmed.range(of: #"^[-*+]\s+"#, options: .regularExpression) {
            let content = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            return Item(marker: .bullet, content: content, level: level)
        }

        return nil
    }

    private func leadingIndent(in line: String) -> Int {
        var count = 0
        for character in line {
            if character == " " { count += 1 }
            else if character == "\t" { count += 4 }
            else { break }
        }
        return count
    }

    private func isThematicBreak(_ line: String) -> Bool {
        line.range(of: #"^(?:-{3,}|\*{3,}|_{3,})$"#, options: .regularExpression) != nil
    }

    private func markerText(for marker: Item.Marker) -> String {
        switch marker {
        case .bullet: return "•"
        case .ordered(let value): return "\(value)."
        }
    }

    private func headingMarkerDetails(from text: String, font: NSFont) -> (marker: String, content: String, style: NSParagraphStyle)? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)

        if let range = trimmed.range(of: #"^\d+\.\s+"#, options: .regularExpression) {
            let marker = String(trimmed[range]).trimmingCharacters(in: .whitespaces)
            let content = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            let style = listParagraphStyle(markerIndent: 0, marker: marker, font: font)
            return (marker, content, style)
        }

        if let range = trimmed.range(of: #"^[-*+]\s+"#, options: .regularExpression) {
            let marker = String(trimmed[range].trimmingCharacters(in: .whitespaces).first ?? "•")
            let content = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            let style = listParagraphStyle(markerIndent: 0, marker: marker, font: font)
            return (marker, content, style)
        }

        return nil
    }

    private func paragraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.paragraphSpacing = 0
        return style
    }

    private func centeredParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }

    private func separatorColor() -> NSColor {
        NSColor.labelColor.withAlphaComponent(0.3)
    }

    private func quoteTextColor() -> NSColor {
        NSColor.secondaryLabelColor
    }

    private func listParagraphStyle(markerIndent: CGFloat, marker: String, font: NSFont? = nil) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        let markerFont = font ?? bodyFont()
        let markerWidth = marker.size(withAttributes: [.font: markerFont]).width
        let contentIndent = markerIndent + markerWidth + 10
        style.firstLineHeadIndent = markerIndent
        style.headIndent = contentIndent
        style.tabStops = [NSTextTab(textAlignment: .left, location: contentIndent)]
        style.defaultTabInterval = contentIndent
        style.lineSpacing = 4
        return style
    }

    private func paragraphStyle(
        _ baseStyle: NSParagraphStyle,
        adjustedForQuoteDepth quoteDepth: Int
    ) -> NSParagraphStyle {
        guard quoteDepth > 0 else { return baseStyle }

        let style = baseStyle.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        let quoteIndent = CGFloat(quoteDepth) * 16
        style.headIndent += quoteIndent
        style.firstLineHeadIndent += quoteIndent
        style.paragraphSpacing = max(style.paragraphSpacing, 4)
        style.paragraphSpacingBefore = max(style.paragraphSpacingBefore, 2)
        return style
    }

    private func headingFont(for level: Int) -> NSFont {
        switch level {
        case 1: return .systemFont(ofSize: bodyFontSize + 11, weight: .bold)
        case 2: return .systemFont(ofSize: bodyFontSize + 6, weight: .bold)
        case 3: return .systemFont(ofSize: bodyFontSize + 3, weight: .semibold)
        case 4: return .systemFont(ofSize: bodyFontSize, weight: .semibold)
        default: return .systemFont(ofSize: bodyFontSize, weight: .regular)
        }
    }

    private func bodyFont() -> NSFont {
        .systemFont(ofSize: bodyFontSize, weight: .regular)
    }
}

private extension NSAttributedString {
    var fullRange: NSRange {
        NSRange(location: 0, length: length)
    }
}
#endif
