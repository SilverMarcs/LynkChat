//
//  MDView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI

struct MDView: View {
    @Environment(\.searchText) private var searchText
    @Environment(\.isReplying) private var isReplying
    
    @ObservedObject var config = AppConfig.shared
    var content: String
    var calculatedHeight: Binding<CGFloat>? = nil

    var body: some View {
        switch config.markdownProvider {
        case .disabled:
            Text(content)
                .textSelection(.enabled)
                .font(.system(size: config.fontSize))
                .lineSpacing(2)
        case .basic:
//            MarkdownView(content: content)
//                .searchText(searchText)
//                .codeBlockFontSize(config.fontSize - 1)
//                .highlightCode(isReplying ? false : true)
//                .textSelection(.enabled)
//                .font(.system(size: config.fontSize))
//                .lineSpacing(2)
//            Text(LocalizedStringKey(content))
//                .textSelection(.enabled)
//                .font(.system(size: config.fontSize))
//                .lineSpacing(2)
            NativeMarkdownView(text: content, highlightText: searchText)
                .textSelection(.enabled)
                .lineSpacing(2)
                .font(.system(size: config.fontSize))
                
        case .webview:
            SwiftMarkdownView(
                content,
                calculatedHeight: calculatedHeight,
                fontSize: CGFloat(config.fontSize),
                highlightString: searchText,
                baseURL: "LynkChat Web Content",
                codeBlockTheme: config.codeBlockTheme
            )
        }
    }
}

#Preview {
    MDView(content: Message.mockAssistantMessage.content)
        .frame(width: 600, height: 500)
        .padding()
}
