import SwiftUI

enum MarkdownPart: Equatable {
    case text(String)
    case codeBlock(String)
    case heading(level: Int, text: String)
    case list(items: [ListItem])
}

struct ListItem: Equatable, Identifiable {
    enum Marker: Equatable {
        case bullet
        case ordered(Int)
    }
    let id = UUID()
    var marker: Marker
    var content: String
    var level: Int // 1 = top-level
    var children: [ListItem] = []
}

struct NativeMarkdownView: View {
    private let parts: [MarkdownPart]
    #if os(macOS)
    @AppStorage("fontSize") var fontSize: Double = 13
    #else
    @AppStorage("fontSize") var fontSize: Double = 17
    #endif
    
    init(text: String) {
        self.parts = NativeMarkdownView.parseMarkdown(text)
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                switch part {
                case .text(let string):
                    Text(LocalizedStringKey(string))
                        .lineSpacing(2)
                        .font(.system(size: fontSize + 1))

                case .codeBlock(let code):
                    GroupBox {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(code)
                                .font(.system(size: fontSize - 1, weight: .regular, design: .monospaced))
                                .textSelection(.enabled)                        }
                    }
                    #if os(macOS)
                    .groupBoxStyle(PlatformGroupBox())
                    #endif

                case .heading(let level, let text):
                    headingView(level: level, text: text)

                case .list(let items):
                    listView(items: items)
                }
            }
        }
        .textSelection(.enabled)
    }

    // MARK: - Heading Rendering

    @ViewBuilder
    private func headingView(level: Int, text: String) -> some View {
        // Map Markdown heading levels to SwiftUI fonts
        let font: Font = {
            switch level {
            case 1: return .system(size: fontSize + 10, weight: .bold)
            case 2: return .system(size: fontSize + 8, weight: .bold)
            case 3: return .system(size: fontSize + 6, weight: .semibold)
            case 4: return .system(size: fontSize + 4, weight: .semibold)
            case 5: return .system(size: fontSize + 2, weight: .medium)
            default: return .system(size: fontSize + 1, weight: .medium)
            }
        }()
        Text(LocalizedStringKey(text))
            .font(font)
            .padding(.top, level == 1 ? 4 : 2)
    }

    // MARK: - List Rendering (Recursive)

    @ViewBuilder
    private func listView(items: [ListItem]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(items) { item in
                ListItemView(
                    item: item,
                    markerViewProvider: { marker in AnyView(markerView(for: marker)) },
                    childViewProvider: { children in AnyView(listView(items: children)) }
                )
            }
        }
    }

    @ViewBuilder
    private func markerView(for marker: ListItem.Marker) -> some View {
        switch marker {
        case .bullet:
            Circle()
                .fill(.primary)
                .frame(width: 4, height: 4)
                .offset(y: -2)
        case .ordered(let n):
            Text("\(n).")
                .font(.system(size: fontSize + 1, weight: .regular, design: .default))
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Parser

    private static func parseMarkdown(_ text: String) -> [MarkdownPart] {
        var parts: [MarkdownPart] = []
        let lines = text.components(separatedBy: .newlines)

        var i = 0
        while i < lines.count {
            let line = lines[i]

            // Handle code blocks (``` or ```lang)
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                var codeLines: [String] = []
                i += 1 // Skip opening ```
                while i < lines.count {
                    let codeLine = lines[i]
                    if codeLine.trimmingCharacters(in: .whitespaces) == "```" {
                        break
                    }
                    codeLines.append(codeLine)
                    i += 1
                }
                parts.append(.codeBlock(codeLines.joined(separator: "\n")))
                i += 1 // Skip closing ```
                continue
            }

            // Handle headings: # .. ###### + space
            if let heading = parseHeading(line: line) {
                parts.append(.heading(level: heading.level, text: heading.text))
                i += 1
                continue
            }

            // Handle list block (bulleted or ordered, supports nesting)
            if isListLine(line) {
                let (listItems, nextIndex) = parseListBlock(from: i, lines: lines)
                parts.append(.list(items: listItems))
                i = nextIndex
                continue
            }

            // Collect consecutive non-special lines as regular text
            var textLines: [String] = []
            while i < lines.count {
                let currentLine = lines[i]
                let trimmed = currentLine.trimmingCharacters(in: .whitespaces)

                if trimmed.hasPrefix("```")
                    || isListLine(currentLine)
                    || parseHeading(line: currentLine) != nil
                {
                    break
                }

                textLines.append(currentLine)
                i += 1
            }

            if !textLines.isEmpty {
                parts.append(.text(textLines.joined(separator: "\n")))
            } else {
                // empty line
                i += 1
            }
        }

        return parts
    }

    // MARK: - Helpers: Headings

    private static func parseHeading(line: String) -> (level: Int, text: String)? {
        // Match leading #'s followed by a space
        // e.g. "### Title"
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.first == "#" else { return nil }
        let hashes = trimmed.prefix { $0 == "#" }
        guard hashes.count >= 1 && hashes.count <= 6 else { return nil }
        let remainder = trimmed.dropFirst(hashes.count)
        guard remainder.first == " " else { return nil }
        let text = remainder.dropFirst().trimmingCharacters(in: .whitespaces)
        return (level: hashes.count, text: String(text))
    }

    // MARK: - Helpers: Lists

    private static func isListLine(_ line: String) -> Bool {
        let s = line
        let pattern = #"^\s*(?:[-*+]\s+|\d+\.\s+)"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }

    private static func parseListBlock(from start: Int, lines: [String]) -> ([ListItem], Int) {
        var i = start
        var rawItems: [ListItem] = []

        // Collect contiguous list lines (stopping at blank line or non-list)
        while i < lines.count {
            let line = lines[i]
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                break
            }
            guard let parsed = parseListLine(line) else { break }
            rawItems.append(parsed)
            i += 1

            // NOTE: For multi-line list items (wrapped paragraphs), you could extend this:
            // while next line is indented more than content indent and not a new marker, append to content...
        }

        // Build hierarchy from levels using a stack
        let tree = buildListTree(from: rawItems)
        return (tree, i)
    }

    private static func parseListLine(_ line: String) -> ListItem? {
        let lineChars = Array(line)
        let spaces = countLeadingSpaces(in: lineChars)
        // Use 2-space steps to define nesting; tabs assumed as 4 spaces
        let level = max(1, spaces / 2 + 1)

        let trimmed = String(line.dropFirst(spaces))

        // Ordered: n. content
        if let orderedRange = trimmed.range(of: #"^\d+\.\s+"#, options: .regularExpression) {
            let markerStr = String(trimmed[orderedRange])
            let numStr = markerStr.trimmingCharacters(in: .whitespaces).dropLast().split(separator: ".").first ?? ""
            let n = Int(numStr) ?? 1
            let content = String(trimmed[orderedRange.upperBound...]).trimmingCharacters(in: .whitespaces)
            return ListItem(marker: .ordered(n), content: content, level: level, children: [])
        }

        // Bulleted: -, *, +
        if let bulletRange = trimmed.range(of: #"^[-*+]\s+"#, options: .regularExpression) {
            let content = String(trimmed[bulletRange.upperBound...]).trimmingCharacters(in: .whitespaces)
            return ListItem(marker: .bullet, content: content, level: level, children: [])
        }

        return nil
    }

    private static func countLeadingSpaces(in chars: [Character]) -> Int {
        var count = 0
        for c in chars {
            if c == " " { count += 1 }
            else if c == "\t" { count += 4 }
            else { break }
        }
        return count
    }

    private static func buildListTree(from items: [ListItem]) -> [ListItem] {
        var result: [ListItem] = []
        var stack: [ListItem] = []

        func appendToCurrent(_ item: ListItem) {
            if stack.isEmpty {
                result.append(item)
                stack = [item]
            } else {
                var top = stack.removeLast()
                if item.level > top.level {
                    // child
                    top.children.append(item)
                    stack.append(top)
                    stack.append(item)
                    // Need to also fix result linkage if top is in result or nested
                    // We re-sync the tree after loop by rebuilding from stack references.
                    // To keep it simple, we’ll reconstruct using indexes below.
                } else {
                    // ascend until we find a parent with lower level
                    var tmp = top
                    var tempStack = stack
                    while item.level <= tmp.level, !tempStack.isEmpty {
                        tmp = tempStack.removeLast()
                    }
                    // Reconstruct the ancestors array to the found parent
                    stack = tempStack
                    if stack.isEmpty {
                        result.append(item)
                        stack = [item]
                    } else {
                        // Append as sibling to the parent's children
                        var parent = stack.removeLast()
                        parent.children.append(item)
                        stack.append(parent)
                        stack.append(item)
                    }
                }
            }
        }

        // Simpler and correct approach: we’ll maintain an array of references through indices.
        result.removeAll()
        var parentIndicesStack: [(arrayRef: UnsafeMutablePointer<[ListItem]>, idx: Int, level: Int)] = unsafe []

        func appendItem(_ item: ListItem) {
            // Find correct parent by level
            while let last = unsafe parentIndicesStack.last, unsafe item.level <= last.level {
                unsafe parentIndicesStack.removeLast()
            }

            if let last = unsafe parentIndicesStack.last {
                // Append to parent's children
                unsafe last.arrayRef.pointee[last.idx].children.append(item)
                let childIdx = unsafe last.arrayRef.pointee[last.idx].children.count - 1
                let ptr = unsafe withUnsafeMutablePointer(to: &last.arrayRef.pointee[last.idx].children) { unsafe $0 }
                unsafe parentIndicesStack.append((arrayRef: ptr, idx: childIdx, level: item.level))
            } else {
                // Append to root
                result.append(item)
                let idx = result.count - 1
                let ptr = unsafe withUnsafeMutablePointer(to: &result) { unsafe $0 }
                unsafe parentIndicesStack.append((arrayRef: ptr, idx: idx, level: item.level))
            }
        }

        for item in items {
            appendItem(item)
        }

        return result
    }
}


struct ListItemView: View {
    #if os(macOS)
    @AppStorage("fontSize") var fontSize: Double = 13
    #else
    @AppStorage("fontSize") var fontSize: Double = 17
    #endif
    let item: ListItem
    let markerViewProvider: (ListItem.Marker) -> AnyView
    let childViewProvider: ([ListItem]) -> AnyView

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                markerViewProvider(item.marker)
                    .frame(width: 16, alignment: .trailing)
//                        .offset(y: -2)

                Text(LocalizedStringKey(item.content))
                    .lineSpacing(2)
                    .font(.system(size: fontSize + 1))
            }
            if !item.children.isEmpty {
                childViewProvider(item.children)
                    .padding(.leading, 16)
            }
        }
    }
}

//extension AttributedString {
//    init(styledMarkdown markdownString: String) throws {
//        var output = try AttributedString(
//            markdown: markdownString,
//            options: .init(
//                allowsExtendedAttributes: true,
//                interpretedSyntax: .full,
//                failurePolicy: .returnPartiallyParsedIfPossible
//            ),
//            baseURL: nil
//        )
//
//        for (intentBlock, intentRange) in output.runs[AttributeScopes.FoundationAttributes.PresentationIntentAttribute.self].reversed() {
//            guard let intentBlock = intentBlock else { continue }
//            for intent in intentBlock.components {
//                switch intent.kind {
//                case .header(level: let level):
//                    switch level {
//                    case 1:
//                        output[intentRange].font = .system(.title).bold()
//                    case 2:
//                        output[intentRange].font = .system(.title2).bold()
//                    case 3:
//                        output[intentRange].font = .system(.title3).bold()
//                    default:
//                        break
//                    }
//                default:
//                    break
//                }
//            }
//            
//            if intentRange.lowerBound != output.startIndex {
//                output.characters.insert(contentsOf: "\n", at: intentRange.lowerBound)
//            }
//        }
//
//        self = output
//    }
//}
