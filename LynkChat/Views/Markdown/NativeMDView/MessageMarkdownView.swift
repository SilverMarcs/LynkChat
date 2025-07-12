//
//  MessageMarkdownView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import MarkdownUI
//import HighlightSwift
import SwiftUI

struct MessageMarkdownView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var config = AppConfig.shared

    var text: String
    var highlightText: String

    var body: some View {
        Markdown(text)
    
//            .font(.system(size: config.fontSize + 2))
//            .markdownBlockStyle(\.codeBlock) {
//                CodeBlock(configuration: $0, highlightText: highlightText)
//            }
            .font(.system(size: config.fontSize - 0.5))
//            .markdownTextStyle(\.paragraph) {
//                FontSize(.em(0.85))
//            }
    }

//    struct CodeBlock: View {
//        let configuration: CodeBlockConfiguration
//        let highlightText: String
//
//        @State private var isButtonPressed = false
//
//        var body: some View {
//            ZStack(alignment: .bottomTrailing) {
//                CodeText(configuration.content)
//                    .highlightedString(highlightText)
//                    .codeTextColors(.theme(.atomOne))
//                    .padding(12)
////                    .background(.background.secondary)
//                    .background(
//                        RoundedRectangle(
//                            cornerRadius: 12,
//                        )
//                        .fill(.background.secondary.opacity(0.3))
//                        .stroke(.quaternary, lineWidth: 1)
//                    )
//                    .markdownMargin(top: .zero, bottom: .em(0.8))
//
//                copyButton
//                    .padding(5)
//            }
//        }
//
//        var copyButton: some View {
//            Button {
//                self.isButtonPressed = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    self.isButtonPressed = false
//                }
//                configuration.content.copyToPasteboard()
//            } label: {
//                Image(systemName: isButtonPressed ? "checkmark" : "clipboard")
//                    .contentTransition(.symbolEffect(.replace, options: .speed(2)))
//                    .frame(width: 10, height: 10)
//                    .padding(10)
//                    .contentShape(.rect)
//                    .glassEffect(in: .rect(cornerRadius: 8, style: .continuous))
//            }
//            .buttonStyle(.plain)
//            .disabled(isButtonPressed)
//        }
//    }
}
