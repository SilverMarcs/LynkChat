import SwiftUI

#if os(macOS)
import AppKit

struct MacMarkdownView: View {
    let text: String
    let fontSize: CGFloat
    var calculatedHeight: Binding<CGFloat>? = nil

    var body: some View {
        MacMarkdownRepresentable(
            blocks: MacMarkdownRenderer(fontSize: fontSize).render(text),
            calculatedHeight: calculatedHeight
        )
    }
}

private struct MacMarkdownRepresentable: NSViewRepresentable {
    let blocks: [MarkdownRenderedBlock]
    var calculatedHeight: Binding<CGFloat>?

    func makeNSView(context: Context) -> MarkdownContainerView {
        MarkdownContainerView()
    }

    func updateNSView(_ nsView: MarkdownContainerView, context: Context) {
        nsView.onHeightChange = { newHeight in
            guard let calculatedHeight, calculatedHeight.wrappedValue != newHeight else { return }
            calculatedHeight.wrappedValue = newHeight
        }
        nsView.update(blocks: blocks)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: MarkdownContainerView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        return nsView.measuredSize(for: width)
    }
}

private final class MarkdownContainerView: NSView {
    private let stackView = NSStackView()
    private var currentWidth: CGFloat = 0
    private var lastReportedHeight: CGFloat = 0
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
            reportHeightIfNeeded(for: currentWidth)
        }
    }

    func measuredSize(for width: CGFloat) -> CGSize {
        currentWidth = width

        for case let measurable as MarkdownMeasurable in stackView.arrangedSubviews {
            measurable.update(preferredWidth: width)
        }

        let fittingHeight = stackView.arrangedSubviews.reduce(CGFloat.zero) { partial, view in
            partial + view.fittingSize.height
        } + CGFloat(max(0, stackView.arrangedSubviews.count - 1)) * stackView.spacing

        return CGSize(width: width, height: ceil(fittingHeight))
    }

    override func layout() {
        super.layout()

        let width = bounds.width > 0 ? bounds.width : currentWidth
        guard width > 0 else { return }

        for case let measurable as MarkdownMeasurable in stackView.arrangedSubviews {
            measurable.update(preferredWidth: width)
        }

        reportHeightIfNeeded(for: width)
    }

    private func reportHeightIfNeeded(for width: CGFloat) {
        let measuredHeight = measuredSize(for: width).height
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
        case .code(let content):
            return MarkdownCodeBlockView(content: content)
        }
    }

    private func configure(view: NSView, with block: MarkdownRenderedBlock) {
        switch (view, block) {
        case let (textView as MarkdownTextBlockView, .text(attributedStrings)):
            textView.update(attributedStrings: attributedStrings)
        case let (codeView as MarkdownCodeBlockView, .code(content)):
            codeView.update(content: content)
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
}

private final class MarkdownCodeTextView: NSTextView {
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
}

private final class MarkdownTextBlockView: NSView, MarkdownMeasurable {
    private let textView = MarkdownPlainTextView()
    private var widthConstraint: NSLayoutConstraint?

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
        let combinedString = NSMutableAttributedString()

        for (index, attributedString) in attributedStrings.enumerated() {
            if index > 0 {
                combinedString.append(NSAttributedString(string: "\n\n"))
            }
            combinedString.append(attributedString)
        }

        textView.markdownTextStorage.setAttributedString(combinedString)
        invalidateIntrinsicContentSize()
    }

    func update(preferredWidth: CGFloat) {
        widthConstraint?.constant = preferredWidth
        textView.frame.size.width = preferredWidth
        textView.markdownTextContainer.containerSize = CGSize(width: preferredWidth, height: .greatestFiniteMagnitude)
        textView.markdownLayoutManager.ensureLayout(for: textView.markdownTextContainer)
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: NSSize {
        measuredSize(for: widthConstraint?.constant ?? bounds.width)
    }

    override var fittingSize: NSSize {
        measuredSize(for: widthConstraint?.constant ?? bounds.width)
    }

    private func measuredSize(for width: CGFloat) -> NSSize {
        guard width > 0 else {
            return .zero
        }

        textView.markdownTextContainer.containerSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        textView.markdownLayoutManager.ensureLayout(for: textView.markdownTextContainer)
        let usedRect = textView.markdownLayoutManager.usedRect(for: textView.markdownTextContainer)
        return NSSize(width: width, height: ceil(usedRect.height))
    }
}

private final class MarkdownCodeBlockView: NSView, MarkdownMeasurable {
    private let backgroundView = NSView()
    private let scrollView = NSScrollView()
    private let textView = MarkdownCodeTextView()
    private let copyButton = NSButton()
    private var widthConstraint: NSLayoutConstraint?
    private var content: String

    init(content: String) {
        self.content = content
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        wantsLayer = true

        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = 12
        backgroundView.layer?.backgroundColor = NSColor(
            calibratedWhite: 0.15,
            alpha: 1
        ).cgColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        copyButton.title = "Copy"
        copyButton.bezelStyle = .rounded
        copyButton.controlSize = .small
        copyButton.target = self
        copyButton.action = #selector(copyCode)
        copyButton.translatesAutoresizingMaskIntoConstraints = false

        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        textView.drawsBackground = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRichText = false
        textView.importsGraphics = false
        textView.textContainerInset = NSSize(width: 0, height: 0)
        textView.markdownTextContainer.lineFragmentPadding = 0
        textView.isHorizontallyResizable = true
        textView.isVerticallyResizable = true
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

            copyButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10),
            copyButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10),

            scrollView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 14),
            scrollView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -14),
            scrollView.topAnchor.constraint(equalTo: copyButton.bottomAnchor, constant: 10),
            scrollView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -14)
        ])

        update(content: content)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(content: String) {
        self.content = content
        textView.markdownTextStorage.setAttributedString(
            NSAttributedString(
                string: content,
                attributes: [
                    .font: textView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular),
                    .foregroundColor: NSColor.white
                ]
            )
        )
        invalidateIntrinsicContentSize()
    }

    func update(preferredWidth: CGFloat) {
        widthConstraint?.constant = preferredWidth
        textView.markdownTextContainer.containerSize = CGSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: NSSize {
        measuredSize(for: widthConstraint?.constant ?? bounds.width)
    }

    override var fittingSize: NSSize {
        measuredSize(for: widthConstraint?.constant ?? bounds.width)
    }

    private func measuredSize(for width: CGFloat) -> NSSize {
        guard width > 0 else { return .zero }

        let contentWidth = max(width - 28, 160)
        let codeSize = (content as NSString).boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: textView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular)]
        ).size

        let bodyHeight = ceil(codeSize.height)
        let totalHeight = 10 + 24 + 10 + bodyHeight + 14
        return NSSize(width: width, height: totalHeight)
    }

    @objc
    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
    }
}

private enum MarkdownRenderedBlock {
    case text([NSAttributedString])
    case code(String)
}

private struct MacMarkdownRenderer {
    private enum Block {
        case paragraph(String)
        case heading(level: Int, text: String)
        case list(items: [Item])
        case quote(String)
        case codeBlock(String)
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

    init(fontSize: CGFloat) {
        self.fontSize = fontSize
        self.bodyFontSize = max(fontSize + 1, 14)
    }

    func render(_ markdown: String) -> [MarkdownRenderedBlock] {
        var renderedBlocks: [MarkdownRenderedBlock] = []
        var pendingTextBlocks: [NSAttributedString] = []

        func flushPendingTextBlocks() {
            guard !pendingTextBlocks.isEmpty else { return }
            renderedBlocks.append(.text(pendingTextBlocks))
            pendingTextBlocks.removeAll(keepingCapacity: true)
        }

        for block in parseBlocks(markdown) {
            switch block {
            case .codeBlock(let code):
                flushPendingTextBlocks()
                renderedBlocks.append(.code(code))
            default:
                pendingTextBlocks.append(attributedBlock(for: block))
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
                var codeLines: [String] = []
                index += 1
                while index < lines.count, lines[index].trimmingCharacters(in: .whitespaces) != "```" {
                    codeLines.append(lines[index])
                    index += 1
                }
                index += 1
                blocks.append(.codeBlock(codeLines.joined(separator: "\n")))
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

    private func attributedBlock(for block: Block) -> NSAttributedString {
        switch block {
        case .paragraph(let text):
            return attributedMarkdown(text, paragraphStyle: paragraphStyle())
        case .heading(let level, let text):
            let heading = NSMutableAttributedString(
                attributedString: attributedMarkdown(text, paragraphStyle: paragraphStyle())
            )
            heading.addAttribute(.font, value: headingFont(for: level), range: heading.fullRange)
            return heading
        case .list(let items):
            return attributedList(items)
        case .quote(let text):
            let quote = NSMutableAttributedString(
                attributedString: attributedMarkdown(text, paragraphStyle: quoteParagraphStyle())
            )
            quote.addAttribute(.backgroundColor, value: NSColor.quaternaryLabelColor.withAlphaComponent(0.12), range: quote.fullRange)
            quote.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: quote.fullRange)
            return quote
        case .codeBlock:
            return NSAttributedString(string: "")
        case .thematicBreak:
            return NSAttributedString(
                string: String(repeating: "─", count: 18),
                attributes: [
                    .font: bodyFont(),
                    .foregroundColor: NSColor.secondaryLabelColor,
                    .paragraphStyle: centeredParagraphStyle()
                ]
            )
        }
    }

    private func attributedList(_ items: [Item]) -> NSAttributedString {
        let output = NSMutableAttributedString()

        for (index, item) in items.enumerated() {
            if index > 0 {
                output.append(NSAttributedString(string: "\n"))
            }

            let marker = markerText(for: item.marker)
            let markerIndent = CGFloat(max(0, item.level - 1)) * 20
            let style = listParagraphStyle(markerIndent: markerIndent, marker: marker)

            let prefix = NSAttributedString(
                string: "\(marker)\t",
                attributes: [
                    .font: bodyFont(),
                    .paragraphStyle: style,
                    .foregroundColor: NSColor.labelColor
                ]
            )

            let content = NSMutableAttributedString(
                attributedString: attributedMarkdown(item.content, paragraphStyle: style)
            )
            content.addAttribute(.paragraphStyle, value: style, range: content.fullRange)

            output.append(prefix)
            output.append(content)
        }

        return output
    }

    private func attributedMarkdown(_ markdown: String, paragraphStyle: NSParagraphStyle) -> NSAttributedString {
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
        parsed.addAttribute(.foregroundColor, value: NSColor.labelColor, range: parsed.fullRange)
        return parsed
    }

    private func normalizeFonts(in attributedString: NSMutableAttributedString) {
        let fullRange = attributedString.fullRange

        if fullRange.length == 0 {
            return
        }

        for location in 0..<fullRange.length {
            let range = NSRange(location: location, length: 1)
            let value = attributedString.attribute(.font, at: location, effectiveRange: nil)

            guard let font = value as? NSFont else {
                attributedString.addAttribute(.font, value: bodyFont(), range: range)
                continue
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
                normalizedFont = .monospacedSystemFont(ofSize: bodyFontSize, weight: weight)
            } else {
                normalizedFont = .systemFont(ofSize: bodyFontSize, weight: weight)
            }

            attributedString.addAttribute(.font, value: normalizedFont, range: range)
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

    private func parseQuote(from startIndex: Int, lines: [String]) -> (String, Int) {
        var index = startIndex
        var quoteLines: [String] = []

        while index < lines.count, isQuoteLine(lines[index]) {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let content = String(trimmed.drop(while: { $0 == ">" || $0 == " " }))
            quoteLines.append(content)
            index += 1
        }

        return (quoteLines.joined(separator: "\n"), index)
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

    private func paragraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.paragraphSpacing = 0
        return style
    }

    private func quoteParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.firstLineHeadIndent = 22
        style.headIndent = 22
        style.paragraphSpacing = 4
        style.paragraphSpacingBefore = 4
        return style
    }

    private func centeredParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }

    private func listParagraphStyle(markerIndent: CGFloat, marker: String) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        let markerWidth = marker.size(withAttributes: [.font: bodyFont()]).width
        let contentIndent = markerIndent + markerWidth + 10
        style.firstLineHeadIndent = markerIndent
        style.headIndent = contentIndent
        style.tabStops = [NSTextTab(textAlignment: .left, location: contentIndent)]
        style.defaultTabInterval = contentIndent
        style.lineSpacing = 4
        return style
    }

    private func headingFont(for level: Int) -> NSFont {
        switch level {
        case 1: return .systemFont(ofSize: bodyFontSize + 15, weight: .bold)
        case 2: return .systemFont(ofSize: bodyFontSize + 11, weight: .bold)
        case 3: return .systemFont(ofSize: bodyFontSize + 7, weight: .semibold)
        case 4: return .systemFont(ofSize: bodyFontSize + 3, weight: .semibold)
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
