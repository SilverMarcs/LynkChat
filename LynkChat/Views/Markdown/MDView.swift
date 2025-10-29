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
    #if os(macOS)
    @AppStorage("fontSize") var fontSize: Double = 13
    #else
    @AppStorage("fontSize") var fontSize: Double = 17
    #endif
    var content: String
    var calculatedHeight: Binding<CGFloat>? = nil

var body: some View {
    #if os(macOS)
    SwiftMarkdownView(
        content,
        calculatedHeight: calculatedHeight,
        fontSize: CGFloat(fontSize),
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
