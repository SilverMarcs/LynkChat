//
//  NativeMarkdownView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI

struct NativeMarkdownView: View {
    var attributed: NSAttributedString

    var body: some View {
        Text(AttributedString(attributed)) // Convert NSAttributedString to AttributedString for SwiftUI Text
    }
    
    init(text: String, highlightText: String) {
        self.attributed = NativeMarkdownView.parseMarkdown(text)
        if !highlightText.isEmpty {
            self.attributed = NativeMarkdownView.applyHighlighting(to: self.attributed, highlightText: highlightText)
        }
    }

    private static func parseMarkdown(_ text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        let scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil

        let baseSize = AppConfig.shared.fontSize
        
        while !scanner.isAtEnd {
            if scanner.scanString("```") != nil {
                let _ = scanner.scanUpToCharacters(from: .newlines) ?? ""
                let _ = scanner.scanCharacters(from: .newlines)
                
                if let codeContent = scanner.scanUpToString("```") {
                    if scanner.scanString("```") != nil {
                        let codeAttribute = NSAttributedString(
                            string: codeContent,
                            attributes: [
                                .font: PlatformFont.monospacedSystemFont(ofSize: baseSize - 1, weight: .regular)
                            ]
                        )
                        attributedString.append(codeAttribute)
                    } else {
                        let fallback = NSAttributedString(
                            string: "```\(codeContent)",
                            attributes: [
                                .font: PlatformFont.systemFont(ofSize: baseSize)
                            ]
                        )
                        attributedString.append(fallback)
                    }
                }
            } else if scanner.scanString("`") != nil {
                if let codeContent = scanner.scanUpToString("`") {
                    if scanner.scanString("`") != nil {
                        let inlineCode = NSAttributedString(
                            string: codeContent,
                            attributes: [
                                .font: PlatformFont.monospacedSystemFont(ofSize: baseSize - 1, weight: .regular),
                                .backgroundColor: PlatformColor.secondarySystemFill
                            ]
                        )
                        attributedString.append(inlineCode)
                    } else {
                        let fallback = NSAttributedString(
                            string: "`\(codeContent)",
                            attributes: [
                                .font: PlatformFont.systemFont(ofSize: baseSize)
                            ]
                        )
                        attributedString.append(fallback)
                    }
                }
            } else if scanner.scanString("**") != nil {
                if let boldContent = scanner.scanUpToString("**") {
                    if scanner.scanString("**") != nil {
                        let bold = NSAttributedString(
                            string: boldContent,
                            attributes: [
                                .font: PlatformFont.boldSystemFont(ofSize: baseSize)
                            ]
                        )
                        attributedString.append(bold)
                    } else {
                        let fallback = NSAttributedString(
                            string: "**\(boldContent)",
                            attributes: [
                                .font: PlatformFont.systemFont(ofSize: baseSize)
                            ]
                        )
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
                    let heading = NSAttributedString(
                        string: headingContent,
                        attributes: [
                            .font: PlatformFont.systemFont(ofSize: headingSize, weight: .bold)
                        ]
                    )
                    attributedString.append(heading)
                }
            } else {
                if let textContent = scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "`*#")) {
                    let text = NSAttributedString(
                        string: textContent,
                        attributes: [
                            .font: PlatformFont.systemFont(ofSize: baseSize)
                        ]
                    )
                    attributedString.append(text)
                } else if let char = scanner.scanCharacter() {
                    let text = NSAttributedString(
                        string: String(char),
                        attributes: [
                            .font: PlatformFont.systemFont(ofSize: baseSize)
                        ]
                    )
                    attributedString.append(text)
                }
            }
        }

        return attributedString
    }

    private static func applyHighlighting(to attributedString: NSAttributedString, highlightText: String) -> NSAttributedString {
        guard !highlightText.isEmpty else { return attributedString }
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        let lowercasedHighlight = highlightText.lowercased()
        let fullRange = NSRange(location: 0, length: mutableAttributedString.length)
        
        let string = mutableAttributedString.string as NSString
        var searchRange = fullRange
        
        while true {
            let range = string.range(
                of: lowercasedHighlight,
                options: .caseInsensitive,
                range: searchRange
            )
            
            if range.location == NSNotFound {
                break
            }
            
            // Apply highlighting to the found range
            mutableAttributedString.addAttributes([
                .backgroundColor: PlatformColor.yellow,
                .foregroundColor: PlatformColor.black
            ], range: range)
            
            // Update search range
            searchRange = NSRange(
                location: range.location + range.length,
                length: fullRange.length - (range.location + range.length)
            )
            
            if searchRange.location >= fullRange.length {
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
