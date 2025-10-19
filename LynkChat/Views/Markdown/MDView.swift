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
    @AppStorage("fontSize") var fontSize: Double = Double.defaultFontSize
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
