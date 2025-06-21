//
//  MDView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import MarkdownUI

struct MDView: View {
    @Environment(\.searchText) private var searchText
    @Environment(\.isReplying) private var isReplying
    @Environment(ChatVM.self) private var chatVM
    
    @ObservedObject var config = AppConfig.shared
    var content: String
    var calculatedHeight: Binding<CGFloat>? = nil

    var body: some View {
        #if os(macOS)
        if !searchText.isEmpty || config.isMarkdownEnabled {
            // Use SwiftMarkdownView when there's search text or markdown is enabled
            SwiftMarkdownView(
                content,
                calculatedHeight: calculatedHeight,
                fontSize: CGFloat(config.fontSize),
                highlightString: searchText,
                baseURL: "LynkChat Web Content",
                codeBlockTheme: config.codeBlockTheme
            )
//            MessageMarkdownView(text: content, highlightText: chatVM.searchText)
//                .textSelection(.enabled)
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
