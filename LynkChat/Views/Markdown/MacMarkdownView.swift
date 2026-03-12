import SwiftUI

#if os(macOS)
import AppKit
import Foundation
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

private final class MarkdownRenderCache {
    let text: String
    let fontSize: CGFloat
    let blocks: [MarkdownRenderedBlock]

    init(text: String, fontSize: CGFloat, blocks: [MarkdownRenderedBlock]) {
        self.text = text
        self.fontSize = fontSize
        self.blocks = blocks
    }
}

private struct MacMarkdownRepresentable: NSViewRepresentable {
    let text: String
    let fontSize: CGFloat
    var calculatedHeight: Binding<CGFloat>?

    final class Coordinator {
        private var cachedRender: MarkdownRenderCache?

        func render(for text: String, fontSize: CGFloat) -> MarkdownRenderCache {
            if let cachedRender, cachedRender.text == text, cachedRender.fontSize == fontSize {
                return cachedRender
            }

            let render = MarkdownRenderCache(
                text: text,
                fontSize: fontSize,
                blocks: MacMarkdownRenderer(fontSize: fontSize).render(text)
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
        let render = context.coordinator.render(for: text, fontSize: fontSize)
        nsView.onHeightChange = { newHeight in
            guard let calculatedHeight, calculatedHeight.wrappedValue != newHeight else { return }
            calculatedHeight.wrappedValue = newHeight
        }
        nsView.update(render: render)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: MarkdownContainerView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        nsView.update(render: context.coordinator.render(for: text, fontSize: fontSize))
        return nsView.measuredSize(for: width)
    }
}

private final class MarkdownContainerView: NSView {
    private let stackView = NSStackView()
    private var currentWidth: CGFloat = 0
    private var lastReportedHeight: CGFloat = 0
    private var lastMeasuredSize: CGSize = .zero
    private var currentRender: MarkdownRenderCache?
    private var needsMeasurement = false
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

    func update(render: MarkdownRenderCache) {
        guard currentRender !== render else {
            recalculateIfNeeded(for: currentWidth, reportHeight: true)
            return
        }

        currentRender = render
        let blocks = render.blocks
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

        needsMeasurement = true
        needsLayout = true
        invalidateIntrinsicContentSize()
        recalculateIfNeeded(for: currentWidth, reportHeight: true)
    }

    func measuredSize(for width: CGFloat) -> CGSize {
        recalculateIfNeeded(for: width, reportHeight: false)
        return lastMeasuredSize
    }

    override func layout() {
        super.layout()

        let width = bounds.width > 0 ? bounds.width : currentWidth
        guard width > 0 else { return }

        recalculateIfNeeded(for: width, reportHeight: true)
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: lastMeasuredSize.width, height: lastMeasuredSize.height)
    }

    private func applyPreferredWidth(_ width: CGFloat) {
        for case let measurable as MarkdownMeasurable in stackView.arrangedSubviews {
            measurable.update(preferredWidth: width)
        }
    }

    private func recalculateIfNeeded(for width: CGFloat, reportHeight: Bool) {
        let resolvedWidth = ceil(width)
        guard resolvedWidth > 0 else { return }

        currentWidth = resolvedWidth

        guard needsMeasurement || lastMeasuredSize.width != resolvedWidth else {
            if reportHeight {
                reportHeightIfNeeded(lastMeasuredSize.height)
            }
            return
        }

        applyPreferredWidth(resolvedWidth)
        let measuredHeight = measureHeight()
        lastMeasuredSize = CGSize(width: resolvedWidth, height: measuredHeight)
        needsMeasurement = false

        if reportHeight {
            reportHeightIfNeeded(measuredHeight)
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
        case .text(let attributedString):
            return MarkdownTextBlockView(attributedString: attributedString)
        case .code(let content, let language, let fontSize):
            return MarkdownCodeBlockView(content: content, language: language, codeFontSize: fontSize)
        }
    }

    private func configure(view: NSView, with block: MarkdownRenderedBlock) {
        switch (view, block) {
        case let (textView as MarkdownTextBlockView, .text(attributedString)):
            textView.update(attributedString: attributedString)
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
    private var currentAttributedString = NSAttributedString()
    private var currentMeasuredSize: NSSize = .zero

    init(attributedString: NSAttributedString) {
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

        update(attributedString: attributedString)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(attributedString: NSAttributedString) {
        guard !currentAttributedString.isEqual(attributedString) else { return }

        currentAttributedString = attributedString
        textView.markdownTextStorage.setAttributedString(attributedString)
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
    case text(NSAttributedString)
    case code(String, language: String?, fontSize: CGFloat)
}

private struct MacMarkdownRenderer {
    private enum Segment {
        case markdown(String)
        case codeBlock(String, language: String?)
    }

    private struct RenderedTextUnit {
        let attributedString: NSAttributedString
        let context: BlockContext
    }

    private struct BlockContext: Equatable {
        enum Kind: Equatable {
            case paragraph
            case heading(Int)
            case listItem(ListContext)
            case thematicBreak
        }

        struct ListContext: Equatable {
            enum Marker: Equatable {
                case bullet
                case ordered(Int)
            }

            let marker: Marker
            let level: Int
            let groupIdentity: Int
        }

        let kind: Kind
        let quoteDepth: Int
        let blockIdentity: Int
    }

    private enum ListMarker {
        case bullet
        case ordered(Int)
    }

    private struct MarkdownListContext {
        let marker: ListMarker
        let level: Int
        let groupIdentity: Int
    }

    private struct MarkdownPresentationContext {
        enum Kind {
            case paragraph
            case heading(Int)
            case thematicBreak
        }

        let kind: Kind
        let quoteDepth: Int
        let blockIdentity: Int
        let listContext: MarkdownListContext?
    }

    private let bodyFontSize: CGFloat
    private let codeFontSize: CGFloat

    init(fontSize: CGFloat) {
        bodyFontSize = max(fontSize, 13)
        codeFontSize = max(bodyFontSize - 1, 12)
    }

    func render(_ markdown: String) -> [MarkdownRenderedBlock] {
        parseSegments(markdown).compactMap { segment in
            switch segment {
            case .markdown(let markdown):
                renderedMarkdownBlock(from: markdown)
            case .codeBlock(let code, let language):
                .code(code, language: language, fontSize: codeFontSize)
            }
        }
    }

    private func renderedMarkdownBlock(from markdown: String) -> MarkdownRenderedBlock? {
        guard !markdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        let attributedString = styledMarkdown(markdown)
        guard attributedString.length > 0 else { return nil }
        return .text(attributedString)
    }

    private func parseSegments(_ markdown: String) -> [Segment] {
        let lines = markdown.components(separatedBy: .newlines)
        var segments: [Segment] = []
        var markdownLines: [String] = []
        var index = 0

        func flushMarkdownLines() {
            let chunk = markdownLines.joined(separator: "\n")
            guard !chunk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                markdownLines.removeAll(keepingCapacity: true)
                return
            }

            segments.append(.markdown(chunk))
            markdownLines.removeAll(keepingCapacity: true)
        }

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("```") {
                flushMarkdownLines()

                let language = parseCodeBlockLanguage(from: trimmed)
                var codeLines: [String] = []
                index += 1

                while index < lines.count, lines[index].trimmingCharacters(in: .whitespaces) != "```" {
                    codeLines.append(lines[index])
                    index += 1
                }

                if index < lines.count {
                    index += 1
                }

                segments.append(.codeBlock(codeLines.joined(separator: "\n"), language: language))
                continue
            }

            markdownLines.append(line)
            index += 1
        }

        flushMarkdownLines()
        return segments
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

    private func styledMarkdown(_ markdown: String) -> NSAttributedString {
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

        let units = renderedTextUnits(from: parsed)
        let output = NSMutableAttributedString()
        var index = 0

        while index < units.count {
            let unit = units[index]

            switch unit.context.kind {
            case .listItem(let listContext):
                if output.length > 0 {
                    output.append(NSAttributedString(string: "\n\n"))
                }

                var isFirstItem = true
                while index < units.count {
                    guard case .listItem(let candidateContext) = units[index].context.kind,
                          candidateContext.groupIdentity == listContext.groupIdentity else {
                        break
                    }

                    if !isFirstItem {
                        output.append(NSAttributedString(string: "\n"))
                    }

                    output.append(styledListItem(units[index]))
                    isFirstItem = false
                    index += 1
                }

            default:
                if output.length > 0 {
                    output.append(NSAttributedString(string: "\n\n"))
                }

                output.append(styledBlock(unit))
                index += 1
            }
        }

        return output
    }

    private func renderedTextUnits(from attributedString: NSAttributedString) -> [RenderedTextUnit] {
        let fullRange = attributedString.fullRange
        guard fullRange.length > 0 else { return [] }

        var units: [RenderedTextUnit] = []
        var currentContext: BlockContext?
        var currentString = NSMutableAttributedString()

        func flushCurrentUnit() {
            guard let currentContext, currentString.length > 0 else { return }
            units.append(
                RenderedTextUnit(
                    attributedString: NSAttributedString(attributedString: currentString),
                    context: currentContext
                )
            )
            currentString = NSMutableAttributedString()
        }

        unsafe attributedString.enumerateAttributes(in: fullRange) { attributes, range, _ in
            let context = blockContext(for: attributes[.markdownPresentationIntent] as? PresentationIntent)
            let substring = NSMutableAttributedString(
                attributedString: attributedString.attributedSubstring(from: range)
            )
            substring.removeAttribute(.markdownPresentationIntent, range: substring.fullRange)
            substring.removeAttribute(.markdownListItemDelimiter, range: substring.fullRange)

            if currentContext == context {
                currentString.append(substring)
            } else {
                flushCurrentUnit()
                currentContext = context
                currentString = substring
            }
        }

        flushCurrentUnit()
        return units
    }

    private func blockContext(for presentationIntent: PresentationIntent?) -> BlockContext {
        let context = presentationContext(for: presentationIntent)

        if let listContext = context.listContext {
            return BlockContext(
                kind: .listItem(
                    .init(
                        marker: listMarker(for: listContext.marker),
                        level: listContext.level,
                        groupIdentity: listContext.groupIdentity
                    )
                ),
                quoteDepth: context.quoteDepth,
                blockIdentity: context.blockIdentity
            )
        }

        let kind: BlockContext.Kind
        switch context.kind {
        case .paragraph:
            kind = .paragraph
        case .heading(let level):
            kind = .heading(level)
        case .thematicBreak:
            kind = .thematicBreak
        }

        return BlockContext(kind: kind, quoteDepth: context.quoteDepth, blockIdentity: context.blockIdentity)
    }

    private func presentationContext(for presentationIntent: PresentationIntent?) -> MarkdownPresentationContext {
        let components = presentationIntent?.components ?? []
        let quoteDepth = components.reduce(into: 0) { count, component in
            if case .blockQuote = component.kind {
                count += 1
            }
        }

        if let thematicBreak = components.first(where: isThematicBreak) {
            return MarkdownPresentationContext(
                kind: .thematicBreak,
                quoteDepth: quoteDepth,
                blockIdentity: thematicBreak.identity,
                listContext: nil
            )
        }

        if let header = components.first(where: isHeader) {
            guard case let .header(level) = header.kind else {
                return MarkdownPresentationContext(
                    kind: .paragraph,
                    quoteDepth: quoteDepth,
                    blockIdentity: header.identity,
                    listContext: nil
                )
            }

            return MarkdownPresentationContext(
                kind: .heading(level),
                quoteDepth: quoteDepth,
                blockIdentity: header.identity,
                listContext: nil
            )
        }

        let paragraph = components.first(where: isParagraph)
        let listItem = components.first(where: isListItem)
        let list = components.first(where: isList)

        let listContext: MarkdownListContext?
        if let listItem, let list {
            let marker: ListMarker
            switch (list.kind, listItem.kind) {
            case (.orderedList, .listItem(let ordinal)):
                marker = .ordered(ordinal)
            default:
                marker = .bullet
            }

            listContext = MarkdownListContext(
                marker: marker,
                level: max(presentationIntent?.indentationLevel ?? 1, 1),
                groupIdentity: list.identity
            )
        } else {
            listContext = nil
        }

        return MarkdownPresentationContext(
            kind: .paragraph,
            quoteDepth: quoteDepth,
            blockIdentity: paragraph?.identity ?? components.first?.identity ?? 0,
            listContext: listContext
        )
    }

    private func isParagraph(_ component: PresentationIntent.IntentType) -> Bool {
        if case .paragraph = component.kind {
            true
        } else {
            false
        }
    }

    private func isHeader(_ component: PresentationIntent.IntentType) -> Bool {
        if case .header = component.kind {
            true
        } else {
            false
        }
    }

    private func isList(_ component: PresentationIntent.IntentType) -> Bool {
        switch component.kind {
        case .orderedList, .unorderedList:
            true
        default:
            false
        }
    }

    private func isListItem(_ component: PresentationIntent.IntentType) -> Bool {
        if case .listItem = component.kind {
            true
        } else {
            false
        }
    }

    private func isThematicBreak(_ component: PresentationIntent.IntentType) -> Bool {
        if case .thematicBreak = component.kind {
            true
        } else {
            false
        }
    }

    private func styledBlock(_ unit: RenderedTextUnit) -> NSAttributedString {
        switch unit.context.kind {
        case .listItem:
            return styledListItem(unit)
        case .thematicBreak:
            return thematicBreakAttributedString(quoteDepth: unit.context.quoteDepth)
        case .paragraph, .heading:
            let output = NSMutableAttributedString(attributedString: unit.attributedString)
            normalizeFonts(in: output)

            let paragraphStyle = paragraphStyle(
                paragraphStyle(),
                adjustedForQuoteDepth: unit.context.quoteDepth
            )
            let foregroundColor = unit.context.quoteDepth > 0 ? quoteTextColor() : NSColor.labelColor

            output.addAttribute(.paragraphStyle, value: paragraphStyle, range: output.fullRange)
            output.addAttribute(.foregroundColor, value: foregroundColor, range: output.fullRange)

            if case .heading(let level) = unit.context.kind {
                output.addAttribute(.font, value: headingFont(for: level), range: output.fullRange)
            }

            applyInlineCodeStyling(to: output)
            return output
        }
    }

    private func styledListItem(_ unit: RenderedTextUnit) -> NSAttributedString {
        guard case .listItem(let listContext) = unit.context.kind else {
            return styledBlock(unit)
        }

        let marker = markerText(for: listContext.marker)
        let markerIndent = CGFloat(max(0, listContext.level - 1)) * 20
        let style = paragraphStyle(
            listParagraphStyle(markerIndent: markerIndent, marker: marker),
            adjustedForQuoteDepth: unit.context.quoteDepth
        )
        let foregroundColor = unit.context.quoteDepth > 0 ? quoteTextColor() : NSColor.labelColor

        let output = NSMutableAttributedString(
            string: "\(marker)\t",
            attributes: [
                .font: bodyFont(),
                .paragraphStyle: style,
                .foregroundColor: foregroundColor
            ]
        )

        let content = NSMutableAttributedString(attributedString: unit.attributedString)
        normalizeFonts(in: content)
        content.addAttribute(.paragraphStyle, value: style, range: content.fullRange)
        content.addAttribute(.foregroundColor, value: foregroundColor, range: content.fullRange)
        applyInlineCodeStyling(to: content)

        output.append(content)
        return output
    }

    private func thematicBreakAttributedString(quoteDepth: Int) -> NSAttributedString {
        NSAttributedString(
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

    private func listMarker(for marker: ListMarker) -> BlockContext.ListContext.Marker {
        switch marker {
        case .bullet:
            return .bullet
        case .ordered(let value):
            return .ordered(value)
        }
    }

    private func normalizeFonts(in attributedString: NSMutableAttributedString) {
        let fullRange = attributedString.fullRange

        if fullRange.length == 0 {
            return
        }

        unsafe attributedString.enumerateAttribute(.font, in: fullRange) { value, range, _ in
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

        unsafe attributedString.enumerateAttribute(.markdownInlinePresentationIntent, in: fullRange) { value, range, _ in
            let isInlineCode: Bool
            if let intent = value as? InlinePresentationIntent {
                isInlineCode = intent.contains(.code)
            } else {
                let rawValue = (value as? NSNumber)?.intValue ?? 0
                isInlineCode = rawValue & 4 != 0
            }

            guard isInlineCode else {
                return
            }

            attributedString.addAttributes([
                .font: NSFont.monospacedSystemFont(ofSize: bodyFontSize, weight: .regular),
                .foregroundColor: NSColor.controlAccentColor
            ], range: range)
        }
    }

    private func markerText(for marker: BlockContext.ListContext.Marker) -> String {
        switch marker {
        case .bullet:
            "•"
        case .ordered(let value):
            "\(value)."
        }
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

private extension NSAttributedString.Key {
    static let markdownInlinePresentationIntent = Self("NSInlinePresentationIntent")
    static let markdownListItemDelimiter = Self("NSListItemDelimiter")
    static let markdownPresentationIntent = Self("NSPresentationIntent")
}
#endif
