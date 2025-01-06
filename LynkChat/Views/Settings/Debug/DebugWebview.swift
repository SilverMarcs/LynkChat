//
//  DebugWebview.swift
//  LynkChat
//
//  Created by Zabir Raihan on 07/01/2025.
//

import SwiftUI
import WebKit

// For macOS, we need a different WebView implementation
#if os(macOS)
struct DebugWebview: NSViewRepresentable {
    let url: URL = URL(string: String.apiHost).map { $0.deletingLastPathComponent() }!
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
#else
// Shared WebView struct that works on both platforms
struct DebugWebview: View {
    @Environment(\.dismiss) var dismiss
    let url: URL = URL(string: String.apiHost).map { $0.deletingLastPathComponent() }!
    
    var body: some View {
        WebViewWrapper(url: url)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white, .regularMaterial)
                        .padding(.leading)
                }
            }
    }
}

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
#endif
