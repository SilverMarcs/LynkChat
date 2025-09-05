//
//  NativeMarkdownView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct NativeMarkdownView: View {
    var attributed: AttributedString

    var body: some View {
        Text(attributed)
    }
    
    init(text: String, highlightText: String) {
        self.attributed = NativeMarkdownView.parseMarkdown(text)
        if !highlightText.isEmpty {
            self.attributed = NativeMarkdownView.applyHighlighting(to: self.attributed, highlightText: highlightText)
        }
    }

    private static func parseMarkdown(_ text: String) -> AttributedString {
        var attributedString = AttributedString()
        
        let scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil

        let baseSize = AppConfig.shared.fontSize
        
        while !scanner.isAtEnd {
            if scanner.scanString("```") != nil {
                let _ = scanner.scanUpToCharacters(from: .newlines) ?? ""
                let _ = scanner.scanCharacters(from: .newlines)
                
                if let codeContent = scanner.scanUpToString("```") {
                    if scanner.scanString("```") != nil {
                        var codeBlock = AttributedString(codeContent)
                        codeBlock.font = .system(size: baseSize - 1, weight: .regular, design: .monospaced)
                        attributedString.append(codeBlock)
                    } else {
                        var fallback = AttributedString("```\(codeContent)")
                        fallback.font = .system(size: baseSize)
                        attributedString.append(fallback)
                    }
                }
            } else if scanner.scanString("`") != nil {
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

#Preview {
    List {
        NativeMarkdownView(text: "Hello, **world**!", highlightText: "")
    }
}
