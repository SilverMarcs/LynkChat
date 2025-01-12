//
//  MDView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
#if !os(macOS)
import MarkdownUI
import HighlightSwift
#endif

struct MDView: View {
    @Environment(\.searchText) private var searchText
    @Environment(\.isReplying) private var isReplying
    
    @ObservedObject var config = AppConfig.shared
    var content: String
    var calculatedHeight: Binding<CGFloat>? = nil

    var body: some View {
        if !searchText.isEmpty {
            // Always use SwiftMarkdownView when there's search text
            SwiftMarkdownView(
                content,
                calculatedHeight: calculatedHeight,
                fontSize: CGFloat(config.fontSize),
                highlightString: searchText,
                baseURL: "LynkChat Web Content",
                codeBlockTheme: config.codeBlockTheme
            )
        } else if config.isMarkdownEnabled {
            #if !os(macOS)
            Markdown(content)
                .textSelection(.enabled)
                .lineSpacing(2)
                .markdownTextStyle {
                    FontSize(config.fontSize)
                }
                .markdownBlockStyle(\.codeBlock) { configuration in
                    CodeText(configuration.content)
                        .codeTextColors(.theme(.atomOne))
                        .font(.system(size: config.fontSize - 2))
                        .padding()
                        .background(.background.secondary.opacity(0.2), in: .rect(cornerRadius: 8))
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.quaternary, lineWidth: 1)
                        }
                        .overlay(alignment: .bottomTrailing) {
                            Button {
                                configuration.content.copyToPasteboard()
                            } label: {
                                Image(systemName: "document.on.clipboard")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .padding()
                        }
                        .padding(.bottom, 12)
                }
            #else
            SwiftMarkdownView(
                content,
                calculatedHeight: calculatedHeight,
                fontSize: CGFloat(config.fontSize),
                highlightString: searchText,
                baseURL: "LynkChat Web Content",
                codeBlockTheme: config.codeBlockTheme
            )
            #endif
            
        } else {
            Text(content)
                .textSelection(.enabled)
                .font(.system(size: config.fontSize))
                .lineSpacing(2)
        }
    }
}

#Preview {
    MDView(content: Message.mockAssistantMessage.content)
        .frame(width: 600, height: 500)
        .padding()
}
