//
//  MDView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
#if os(macOS)
import SwiftMarkdownView
#endif

struct MDView: View {
    @State var config = AppConfig()
    var content: String
    var calculatedHeight: Binding<CGFloat>? = nil

var body: some View {
    #if os(macOS)
    SwiftMarkdownView(
        content,
        calculatedHeight: calculatedHeight,
        fontSize: CGFloat(config.fontSize),
        baseURL: "LynkChat Web Content",
    )
    #else
    NativeMarkdownView(text: content)
    #endif
    }
}

#Preview {
    MDView(content: Message.mockAssistantMessage.content)
        .frame(width: 600, height: 500)
        .padding()
}
