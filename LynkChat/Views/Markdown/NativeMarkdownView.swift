//
//  NativeMarkdownView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

enum MarkdownPart {
    case text(AttributedString)
    case codeBlock(String)
    case listItem(AttributedString)
}

struct NativeMarkdownView: View {
    private let parts: [MarkdownPart]
    private let highlightText: String
    @ObservedObject var config = AppConfig.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                switch part {
                case .text(let attributed):
                    Text(attributed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: config.fontSize + 1))
                    
                case .codeBlock(let code):
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(code)
                            .font(.system(size: config.fontSize - 1, weight: .regular, design: .monospaced))
                            .padding(12)
                            .background(.background.secondary)
                            .cornerRadius(8)
                    }
                    
                case .listItem(let attributed):
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(.primary)
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)
                        
                        Text(attributed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: config.fontSize + 1))
                    }
                }
            }
        }
        .lineSpacing(2)
    }
    
    init(text: String, highlightText: String) {
        self.highlightText = highlightText
        self.parts = NativeMarkdownView.parseMarkdown(text, highlightText: highlightText)
    }

    private static func parseMarkdown(_ text: String, highlightText: String) -> [MarkdownPart] {
        var parts: [MarkdownPart] = []
        let lines = text.components(separatedBy: .newlines)
        
        var i = 0
        while i < lines.count {
            let line = lines[i]
            
            // Handle code blocks
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                var codeLines: [String] = []
                i += 1 // Skip the opening ```
                
                while i < lines.count {
                    let codeLine = lines[i]
                    if codeLine.trimmingCharacters(in: .whitespaces) == "```" {
                        break
                    }
                    codeLines.append(codeLine)
                    i += 1
                }
                
                let codeContent = codeLines.joined(separator: "\n")
                parts.append(.codeBlock(codeContent))
                i += 1 // Skip the closing ```
                continue
            }
            
            // Handle list items
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.hasPrefix("- ") || trimmedLine.hasPrefix("* ") || trimmedLine.hasPrefix("+ ") {
                let listContent = String(trimmedLine.dropFirst(2))
                let attributed = parseInlineMarkdown(listContent, highlightText: highlightText)
                parts.append(.listItem(attributed))
                i += 1
                continue
            }
            
            // Handle numbered lists
            if let match = trimmedLine.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                let listContent = String(trimmedLine[match.upperBound...])
                let attributed = parseInlineMarkdown(listContent, highlightText: highlightText)
                parts.append(.listItem(attributed))
                i += 1
                continue
            }
            
            // Collect consecutive non-special lines as regular text
            var textLines: [String] = []
            while i < lines.count {
                let currentLine = lines[i]
                let trimmed = currentLine.trimmingCharacters(in: .whitespaces)
                
                // Break if we encounter special markdown
                if trimmed.hasPrefix("```") ||
                   trimmed.hasPrefix("- ") ||
                   trimmed.hasPrefix("* ") ||
                   trimmed.hasPrefix("+ ") ||
                   trimmed.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
                    break
                }
                
                textLines.append(currentLine)
                i += 1
            }
            
            if !textLines.isEmpty {
                let textContent = textLines.joined(separator: "\n")
                let attributed = parseInlineMarkdown(textContent, highlightText: highlightText)
                parts.append(.text(attributed))
            }
        }
        
        return parts
    }

    private static func parseInlineMarkdown(_ text: String, highlightText: String) -> AttributedString {
        var attributedString = AttributedString()
        
        let scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil

        let baseSize = AppConfig.shared.fontSize
        
        while !scanner.isAtEnd {
            if scanner.scanString("`") != nil {
                if let codeContent = scanner.scanUpToString("`") {
                    if scanner.scanString("`") != nil {
                        var inlineCode = AttributedString(codeContent)
                        inlineCode.font = .system(size: baseSize - 1, weight: .regular, design: .monospaced)
                        inlineCode.backgroundColor = .secondary.opacity(0.2)
                        attributedString.append(inlineCode)
                    } else {
                        var fallback = AttributedString("`\(codeContent)")
                        fallback.font = .system(size: baseSize)
                        attributedString.append(fallback)
                    }
                }
            } else if scanner.scanString("**") != nil {
                if let boldContent = scanner.scanUpToString("**") {
                    if scanner.scanString("**") != nil {
                        var bold = AttributedString(boldContent)
                        bold.font = .system(size: baseSize, weight: .bold)
                        attributedString.append(bold)
                    } else {
                        var fallback = AttributedString("**\(boldContent)")
                        fallback.font = .system(size: baseSize)
                        attributedString.append(fallback)
                    }
                }
            } else if scanner.scanString("*") != nil {
                if let italicContent = scanner.scanUpToString("*") {
                    if scanner.scanString("*") != nil {
                        var italic = AttributedString(italicContent)
                        italic.font = .system(size: baseSize, weight: .regular).italic()
                        attributedString.append(italic)
                    } else {
                        var fallback = AttributedString("*\(italicContent)")
                        fallback.font = .system(size: baseSize)
                        attributedString.append(fallback)
                    }
                }
            } else if scanner.scanString("#") != nil {
                var headingLevel = 1
                while scanner.scanString("#") != nil {
                    headingLevel += 1
                }
                let _ = scanner.scanCharacters(from: .whitespaces)
                if let headingContent = scanner.scanUpToCharacters(from: .newlines) {
                    let headingSize: CGFloat = baseSize * (2.0 - (0.3 * CGFloat(headingLevel - 1)))
                    var heading = AttributedString(headingContent)
                    heading.font = .system(size: headingSize, weight: .bold)
                    attributedString.append(heading)
                }
            } else {
                if let textContent = scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "`*#")) {
                    var text = AttributedString(textContent)
                    text.font = .system(size: baseSize)
                    attributedString.append(text)
                } else if let char = scanner.scanCharacter() {
                    var text = AttributedString(String(char))
                    text.font = .system(size: baseSize)
                    attributedString.append(text)
                }
            }
        }

        // Apply highlighting if needed
        if !highlightText.isEmpty {
            attributedString = applyHighlighting(to: attributedString, highlightText: highlightText)
        }

        return attributedString
    }

    private static func applyHighlighting(to attributedString: AttributedString, highlightText: String) -> AttributedString {
        guard !highlightText.isEmpty else { return attributedString }
        
        var mutableAttributedString = attributedString
        let lowercasedHighlight = highlightText.lowercased()
        let fullString = String(attributedString.characters)
        
        var searchStartIndex = fullString.startIndex
        
        while searchStartIndex < fullString.endIndex {
            if let range = fullString.range(
                of: lowercasedHighlight,
                options: .caseInsensitive,
                range: searchStartIndex..<fullString.endIndex
            ) {
                // Convert String.Index range to AttributedString.Index range
                let startDistance = fullString.distance(from: fullString.startIndex, to: range.lowerBound)
                let endDistance = fullString.distance(from: fullString.startIndex, to: range.upperBound)
                
                let attrStartIndex = mutableAttributedString.index(mutableAttributedString.startIndex, offsetByCharacters: startDistance)
                let attrEndIndex = mutableAttributedString.index(mutableAttributedString.startIndex, offsetByCharacters: endDistance)
                
                let attrRange = attrStartIndex..<attrEndIndex
                
                // Apply highlighting to the found range
                mutableAttributedString[attrRange].backgroundColor = .yellow
                mutableAttributedString[attrRange].foregroundColor = .black
                
                // Update search start position
                searchStartIndex = range.upperBound
            } else {
                break
            }
        }
        
        return mutableAttributedString
    }
}

//#Preview {
//    ScrollView {
//        VStack(alignment: .leading, spacing: 16) {
//            NativeMarkdownView(text: """
//            # Heading 1
//            This is regular text with **bold** and *italic* formatting.
//            
//            ## List Example
//            - First item
//            - Second item with **bold text**
//            - Third item
//            
//            ### Code Block
//            ```swift
//            func hello() {
//                print("Hello, World!")
//            }
//            ```
//            
//            Regular text with `inline code` here.
//            
//            1. Numbered item one
//            2. Numbered item two
//            3. Numbered item three
//            """, highlightText: "")
//            .padding()
//        }
//    }
//}
