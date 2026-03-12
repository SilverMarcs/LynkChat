import AppKit
import Foundation
import Highlightr

#if os(macOS)
struct MarkdownRenderedDocument {
    let attributedString: NSAttributedString
    let codeBlocks: [MarkdownCodeBlock]
    let quoteBlocks: [MarkdownQuoteBlock]
}

struct MarkdownCodeBlock {
    let id: Int
    let range: NSRange
    let content: String
}

struct MarkdownQuoteBlock {
    let range: NSRange
    let depth: Int
    let identity: Int
}

struct MacMarkdownRenderer {
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
        let quoteIdentity: Int?
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
        let quoteIdentity: Int?
        let blockIdentity: Int
        let listContext: MarkdownListContext?
    }

    private let bodyFontSize: CGFloat
    private let codeFontSize: CGFloat
    private let themeName: String

    init(fontSize: CGFloat, themeName: String) {
        bodyFontSize = max(fontSize, 13)
        codeFontSize = max(bodyFontSize - 1, 12)
        self.themeName = themeName
    }

    func render(_ markdown: String) -> MarkdownRenderedDocument {
        let output = NSMutableAttributedString()
        var codeBlocks: [MarkdownCodeBlock] = []
        var quoteBlocks: [MarkdownQuoteBlock] = []
        var nextCodeBlockID = 0

        for segment in parseSegments(markdown) {
            let attributedSegment: NSAttributedString?

            switch segment {
            case .markdown(let markdown):
                attributedSegment = renderedMarkdownSegment(from: markdown)
            case .codeBlock(let code, let language):
                attributedSegment = renderedCodeBlock(
                    content: code,
                    language: language,
                    blockID: nextCodeBlockID
                )
                nextCodeBlockID += 1
            }

            guard let attributedSegment, attributedSegment.length > 0 else { continue }

            if output.length > 0 {
                output.append(NSAttributedString(string: "\n\n"))
            }

            let range = NSRange(location: output.length, length: attributedSegment.length)
            output.append(attributedSegment)

            if case .codeBlock(let content, _) = segment {
                codeBlocks.append(
                    MarkdownCodeBlock(
                        id: nextCodeBlockID - 1,
                        range: range,
                        content: content
                    )
                )
            }

            if case .markdown(let markdownSegment) = segment {
                mergeQuoteBlocks(
                    &quoteBlocks,
                    with: renderedQuoteBlocks(
                        from: markdownSegment,
                        in: attributedSegment,
                        at: range.location
                    )
                )
            }
        }

        return MarkdownRenderedDocument(
            attributedString: output,
            codeBlocks: codeBlocks,
            quoteBlocks: quoteBlocks
        )
    }

    private func renderedMarkdownSegment(from markdown: String) -> NSAttributedString? {
        guard !markdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        let attributedString = styledMarkdown(markdown)
        guard attributedString.length > 0 else { return nil }
        return attributedString
    }

    private func renderedCodeBlock(content: String, language: String?, blockID: Int) -> NSAttributedString {
        let highlighter = Highlightr()
        highlighter?.setTheme(to: themeName)

        let codeFont = NSFont.monospacedSystemFont(ofSize: codeFontSize, weight: .regular)
        let output: NSMutableAttributedString

        if let highlighted = highlighter?.highlight(content, as: language) {
            output = NSMutableAttributedString(attributedString: highlighted)
        } else {
            output = NSMutableAttributedString(
                string: content,
                attributes: [.foregroundColor: NSColor.labelColor]
            )
        }

        output.addAttributes([
            .font: codeFont,
            .paragraphStyle: codeBlockParagraphStyle(),
            .markdownCodeBlockID: blockID
        ], range: output.fullRange)

        return output
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
                quoteIdentity: context.quoteIdentity,
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

        return BlockContext(
            kind: kind,
            quoteDepth: context.quoteDepth,
            quoteIdentity: context.quoteIdentity,
            blockIdentity: context.blockIdentity
        )
    }

    private func presentationContext(for presentationIntent: PresentationIntent?) -> MarkdownPresentationContext {
        let components = presentationIntent?.components ?? []
        let quoteIdentity = components.first { component in
            if case .blockQuote = component.kind {
                true
            } else {
                false
            }
        }?.identity
        let quoteDepth = components.reduce(into: 0) { count, component in
            if case .blockQuote = component.kind {
                count += 1
            }
        }

        if let thematicBreak = components.first(where: isThematicBreak) {
            return MarkdownPresentationContext(
                kind: .thematicBreak,
                quoteDepth: quoteDepth,
                quoteIdentity: quoteIdentity,
                blockIdentity: thematicBreak.identity,
                listContext: nil
            )
        }

        if let header = components.first(where: isHeader) {
            guard case let .header(level) = header.kind else {
                return MarkdownPresentationContext(
                    kind: .paragraph,
                    quoteDepth: quoteDepth,
                    quoteIdentity: quoteIdentity,
                    blockIdentity: header.identity,
                    listContext: nil
                )
            }

            return MarkdownPresentationContext(
                kind: .heading(level),
                quoteDepth: quoteDepth,
                quoteIdentity: quoteIdentity,
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
            quoteIdentity: quoteIdentity,
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

    private func codeBlockParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        style.firstLineHeadIndent = 14
        style.headIndent = 14
        style.tailIndent = -14
        style.lineBreakMode = .byCharWrapping
        return style
    }

    private func renderedQuoteBlocks(
        from markdown: String,
        in attributedString: NSAttributedString,
        at location: Int
    ) -> [MarkdownQuoteBlock] {
        guard !markdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }

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
        guard !units.isEmpty else { return [] }

        var quoteBlocks: [MarkdownQuoteBlock] = []
        var renderedLocation = location
        var index = 0

        while index < units.count {
            let unit = units[index]
            let hasLeadingSpacing = renderedLocation > location
            let segmentStart = renderedLocation + (hasLeadingSpacing ? 2 : 0)
            let segmentLength: Int

            switch unit.context.kind {
            case .listItem(let listContext):
                var length = 0
                var isFirstItem = true

                while index < units.count {
                    guard case .listItem(let candidateContext) = units[index].context.kind,
                          candidateContext.groupIdentity == listContext.groupIdentity else {
                        break
                    }

                    if !isFirstItem {
                        length += 1
                    }

                    length += styledListItem(units[index]).length
                    isFirstItem = false
                    index += 1
                }

                segmentLength = length

            default:
                segmentLength = styledBlock(unit).length
                index += 1
            }

            if unit.context.quoteDepth > 0, segmentLength > 0 {
                let maxLength = max(0, (location + attributedString.length) - segmentStart)
                let clampedLength = min(segmentLength, maxLength)

                if clampedLength > 0 {
                    quoteBlocks.append(
                        MarkdownQuoteBlock(
                            range: NSRange(location: segmentStart, length: clampedLength),
                            depth: unit.context.quoteDepth,
                            identity: unit.context.quoteIdentity ?? unit.context.blockIdentity
                        )
                    )
                }
            }

            renderedLocation = segmentStart + segmentLength
        }

        return quoteBlocks
    }

    private func mergeQuoteBlocks(_ quoteBlocks: inout [MarkdownQuoteBlock], with newBlocks: [MarkdownQuoteBlock]) {
        for block in newBlocks {
            guard let lastBlock = quoteBlocks.last else {
                quoteBlocks.append(block)
                continue
            }

            let lastBlockEnd = lastBlock.range.location + lastBlock.range.length
            let gapLength = block.range.location - lastBlockEnd

            if lastBlock.identity == block.identity,
               lastBlock.depth == block.depth,
               gapLength >= 0,
               gapLength <= 2 {
                quoteBlocks[quoteBlocks.count - 1] = MarkdownQuoteBlock(
                    range: NSRange(
                        location: lastBlock.range.location,
                        length: (block.range.location + block.range.length) - lastBlock.range.location
                    ),
                    depth: block.depth,
                    identity: block.identity
                )
            } else {
                quoteBlocks.append(block)
            }
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
    static let markdownCodeBlockID = Self("LynkChatMarkdownCodeBlockID")
}
#endif
