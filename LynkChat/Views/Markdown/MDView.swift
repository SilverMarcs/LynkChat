//
//  MDView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI

struct MDView: View {
    @AppStorage("fontSize") var fontSize: Double = 13
    var content: String
    var isStreaming: Bool = false
    var calculatedHeight: Binding<CGFloat>? = nil

    var body: some View {
        #if os(macOS)
        MacMarkdownView(
            text: content,
            fontSize: CGFloat(fontSize),
            isStreaming: isStreaming,
            calculatedHeight: calculatedHeight
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
