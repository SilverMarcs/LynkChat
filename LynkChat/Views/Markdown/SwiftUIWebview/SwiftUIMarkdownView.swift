//
//  SwiftUIMarkdownView.swift
//  LynkChat
//
//  Created by Assistant on 24/06/2025.
//

import SwiftUI
import WebKit

@available(iOS 26.0, macOS 26.0, *)
struct SwiftUIMarkdownView: View {
    var markdownContent: String
    var calculatedHeight: Binding<CGFloat>?
    var enableMarkdown: Bool
    var fontSize: CGFloat
    var highlightString: String
    var baseURL: String
    var codeBlockTheme: CodeBlockTheme
    
    @State private var webPage = WebPage()
    @State private var contentHeight: CGFloat = 0
    @State private var isInitialized = false
    
    public init(
        _ markdownContent: String,
        calculatedHeight: Binding<CGFloat>? = nil,
        enableMarkdown: Bool = true,
        fontSize: CGFloat = 16,
        highlightString: String = "",
        baseURL: String = "",
        codeBlockTheme: CodeBlockTheme = .github
    ) {
        self.markdownContent = markdownContent
        self.calculatedHeight = calculatedHeight
        self.enableMarkdown = enableMarkdown
        self.fontSize = fontSize
        self.highlightString = highlightString
        self.baseURL = baseURL
        self.codeBlockTheme = codeBlockTheme
    }
    
    var body: some View {
        WebView(webPage)
            .frame(height: contentHeight > 0 ? contentHeight : nil)
            .webViewBackForwardNavigationGestures(.disabled)
            .webViewContentBackground(.hidden)
//            .webViewScrollInputBehavior(.disabled, for: .vertical))
            .webViewMagnificationGestures(.disabled)
//            .webViewContextMenu { _ in
//                EmptyView()
//            }
            .onAppear {
                if !isInitialized {
                    setupWebPage()
                    isInitialized = true
                }
            }
            .onChange(of: markdownContent) { _, _ in
                if isInitialized {
                    updateContent()
                }
            }
            .onChange(of: highlightString) { _, _ in
                if isInitialized {
                    updateContent()
                }
            }
            .onChange(of: fontSize) { _, _ in
                if isInitialized {
                    updateContent()
                }
            }
            .onChange(of: codeBlockTheme) { _, _ in
                if isInitialized {
                    setupWebPage()
                }
            }
            .onChange(of: enableMarkdown) { _, _ in
                if isInitialized {
                    updateContent()
                }
            }
    }
    
    private func setupWebPage() {
        let resources = ResourceLoader.shared
        let htmlString = resources.getCachedHTMLString(with: codeBlockTheme)
        let baseURLForLoad = URL(string: baseURL) ?? URL(string: "about:blank")!
        
        // Configure the web page
        var configuration = WebPage.Configuration()
        configuration.suppressesIncrementalRendering = false
        configuration.allowsInlinePredictions = false
        
        #if os(macOS)
        configuration.userInterfaceDirectionPolicy = .content
        #endif
        
//        let navigationDecider = MarkdownNavigationDecider()
        webPage = WebPage(configuration: configuration)
        
        // Load the HTML content
        _ = webPage.load(html: htmlString, baseURL: baseURLForLoad)
        
        // Update content after the page loads
        Task {
            // Wait for the page to finish loading
            while webPage.isLoading {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
            await MainActor.run {
                updateContent()
            }
        }
    }
    
    private func updateContent() {
        guard !webPage.isLoading else {
            // If still loading, retry after a short delay
            Task {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                await MainActor.run {
                    updateContent()
                }
            }
            return
        }
        
        let data: [String: Any] = [
            "markdownContent": markdownContent,
            "highlightString": highlightString,
            "fontSize": fontSize,
            "codeBlockTheme": codeBlockTheme.rawValue,
            "enableMarkdown": enableMarkdown
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                Task {
                    do {
                        try await webPage.callJavaScript("window.updateWithMarkdownContent(\(jsonString))", arguments: [:])
                        await calculateHeight()
                    } catch {
                        print("Error updating markdown content: \(error)")
                    }
                }
            }
        } catch {
            print("Error converting to JSON: \(error)")
        }
    }
    
    private func calculateHeight() async {
        do {
            let result = try await webPage.callJavaScript("document.body.scrollHeight", arguments: [:])
            if let height = result as? Double {
                await MainActor.run {
                    let newHeight = CGFloat(height)
                    if newHeight != contentHeight {
                        contentHeight = newHeight
                        calculatedHeight?.wrappedValue = newHeight
                    }
                }
            }
        } catch {
            print("Error calculating height: \(error)")
        }
    }
}
