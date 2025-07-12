//
//  MDView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import MarkdownUI

struct MDView: View {
    @ObservedObject var config = AppConfig.shared
    var content: String
    var calculatedHeight: Binding<CGFloat>? = nil

    var body: some View {
        #if os(macOS)
        if config.isMarkdownEnabled {
            // Use SwiftMarkdownView when there's search text or markdown is enabled
            SwiftMarkdownView(
                content,
                calculatedHeight: calculatedHeight,
                fontSize: CGFloat(config.fontSize),
//                highlightString: searchText,
                baseURL: "LynkChat Web Content",
                codeBlockTheme: config.codeBlockTheme
            )
//            MessageMarkdownView(text: content, highlightText: chatVM.searchText)
//                .textSelection(.enabled)
//            SwiftUIMarkdownView(
//                content,
//                calculatedHeight: calculatedHeight,
//                fontSize: CGFloat(config.fontSize),
//                highlightString: searchText,
//                baseURL: "LynkChat Web Content",
//                codeBlockTheme: config.codeBlockTheme
//            )
        } else {
            Text(content)
                .textSelection(.enabled)
                .font(.system(size: config.fontSize))
                .lineSpacing(2)
        }
        #else
        Markdown {
            content
        }
        #endif
    }
}

#Preview {
    MDView(content: Message.mockAssistantMessage.content)
        .frame(width: 600, height: 500)
        .padding()
}
