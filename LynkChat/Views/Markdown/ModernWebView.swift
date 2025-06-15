// //
// //  ModernWebView.swift
// //  LynkChat
// //
// //  Created by Zabir Raihan on 15/6/25.
// //

// import SwiftUI
// import WebKit

// @available(iOS 26.0, macOS 26.0, *)
// struct ModernWebView: View {
//     let content: String
//     let fontSize: CGFloat
//     let highlightString: String
// //    let codeBlockTheme: String
//     let enableMarkdown: Bool
    
//     @State private var webPage = WebPage()
//     @State private var contentHeight: CGFloat = 0
    
//     public init(
//         content: String,
//         fontSize: CGFloat = 16,
//         highlightString: String = "",
// //        codeBlockTheme: String = "github",
//         enableMarkdown: Bool = true
//     ) {
//         self.content = content
//         self.fontSize = fontSize
//         self.highlightString = highlightString
// //        self.codeBlockTheme = codeBlockTheme
//         self.enableMarkdown = enableMarkdown
//     }
    
//     var body: some View {
//         WebView(webPage)
//             .frame(height: max(contentHeight, 100))
//             .onAppear {
//                 loadContent()
//             }
//             .onChange(of: content) { _, _ in
//                 loadContent()
//             }
//             .onChange(of: fontSize) { _, _ in
//                 loadContent()
//             }
//             .onChange(of: highlightString) { _, _ in
//                 loadContent()
//             }
// //            .onChange(of: codeBlockTheme) { _, _ in
// //                loadContent()
// //            }
//     }
    
//     private func loadContent() {
//         let htmlContent = generateHTML()
//         webPage.load(html: htmlContent, baseURL: Bundle.main.bundleURL)
        
//         // Set up JavaScript to measure content height
//         Task {
//             try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
//             await measureContentHeight()
//         }
//     }
    
//     private func generateHTML() -> String {
//         let cssContent = generateCSS()
//         let jsContent = generateJavaScript()
        
//         // Convert markdown to HTML if needed
//         let htmlBody: String
//         if enableMarkdown {
//             // For MVP, we'll use a simple markdown-like conversion
//             // In a full implementation, you'd use a proper markdown parser
//             htmlBody = convertMarkdownToHTML(content)
//         } else {
//             htmlBody = "<pre>\(escapeHTML(content))</pre>"
//         }
        
//         return """
//         <!DOCTYPE html>
//         <html>
//         <head>
//             <meta charset="UTF-8">
//             <meta name="viewport" content="width=device-width, initial-scale=1.0">
//             <style>\(cssContent)</style>
//         </head>
//         <body>
//             <div id="content">\(htmlBody)</div>
//             <script>\(jsContent)</script>
//         </body>
//         </html>
//         """
//     }
    
//     private func generateCSS() -> String {
//         let themeColors = getThemeColors()
        
//         return """
//         body {
//             font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
//             font-size: \(fontSize)px;
//             line-height: 1.6;
//             margin: 0;
//             padding: 16px;
//             background: transparent;
//             color: \(themeColors.text);
//         }
        
//         #content {
//             max-width: 100%;
//             word-wrap: break-word;
//         }
        
//         pre, code {
//             font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace;
//             background: \(themeColors.codeBackground);
//             color: \(themeColors.codeText);
//             border-radius: 6px;
//         }
        
//         pre {
//             padding: 12px;
//             overflow-x: auto;
//             border: 1px solid \(themeColors.border);
//         }
        
//         code {
//             padding: 2px 4px;
//         }
        
//         h1, h2, h3, h4, h5, h6 {
//             margin-top: 24px;
//             margin-bottom: 16px;
//             font-weight: 600;
//             line-height: 1.25;
//         }
        
//         h1 { font-size: \(fontSize * 2)px; }
//         h2 { font-size: \(fontSize * 1.5)px; }
//         h3 { font-size: \(fontSize * 1.25)px; }
        
//         p {
//             margin-bottom: 16px;
//         }
        
//         ul, ol {
//             margin-bottom: 16px;
//             padding-left: 20px;
//         }
        
//         li {
//             margin-bottom: 4px;
//         }
        
//         blockquote {
//             margin: 16px 0;
//             padding: 0 16px;
//             border-left: 4px solid \(themeColors.accent);
//             background: \(themeColors.blockquoteBackground);
//         }
        
//         .highlight {
//             background-color: yellow;
//             color: black;
//         }
        
//         table {
//             border-collapse: collapse;
//             width: 100%;
//             margin-bottom: 16px;
//         }
        
//         th, td {
//             border: 1px solid \(themeColors.border);
//             padding: 8px 12px;
//             text-align: left;
//         }
        
//         th {
//             background: \(themeColors.tableHeader);
//             font-weight: 600;
//         }
//         """
//     }
    
//     private func generateJavaScript() -> String {
//         return """
//         function highlightText() {
//             const searchTerm = '\(highlightString)';
//             if (!searchTerm) return;
            
//             const walker = document.createTreeWalker(
//                 document.body,
//                 NodeFilter.SHOW_TEXT,
//                 null,
//                 false
//             );
            
//             const textNodes = [];
//             let node;
//             while (node = walker.nextNode()) {
//                 if (node.textContent.toLowerCase().includes(searchTerm.toLowerCase())) {
//                     textNodes.push(node);
//                 }
//             }
            
//             textNodes.forEach(textNode => {
//                 const text = textNode.textContent;
//                 const escapedTerm = searchTerm.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&');
//                 const regex = new RegExp('(' + escapedTerm + ')', 'gi');
//                 const highlightedText = text.replace(regex, '<span class="highlight">$1</span>');
                
//                 if (highlightedText !== text) {
//                     const tempDiv = document.createElement('div');
//                     tempDiv.innerHTML = highlightedText;
                    
//                     while (tempDiv.firstChild) {
//                         textNode.parentNode.insertBefore(tempDiv.firstChild, textNode);
//                     }
//                     textNode.remove();
//                 }
//             });
//         }
        
//         function notifyHeightChange() {
//             const height = document.body.scrollHeight;
//             // For now, we'll just log the height since WebPage doesn't have message handlers like WKWebView
//             console.log('Content height:', height);
//         }
        
//         document.addEventListener('DOMContentLoaded', function() {
//             highlightText();
//             notifyHeightChange();
            
//             // Observe content changes
//             const observer = new ResizeObserver(notifyHeightChange);
//             observer.observe(document.body);
//         });
//         """
//     }
    
//     private func getThemeColors() -> (text: String, codeBackground: String, codeText: String, border: String, accent: String, blockquoteBackground: String, tableHeader: String) {
//         // Basic theme colors - in a full implementation, you'd read from system appearance
//         return (
//             text: "#000000",
//             codeBackground: "#f6f8fa",
//             codeText: "#24292f",
//             border: "#d1d9e0",
//             accent: "#0969da",
//             blockquoteBackground: "#f6f8fa",
//             tableHeader: "#f6f8fa"
//         )
//     }
    
//     private func convertMarkdownToHTML(_ markdown: String) -> String {
//         var html = escapeHTML(markdown)
        
//         // Simple markdown conversions for MVP
//         // Headers
//         html = html.replacingOccurrences(of: "### ", with: "<h3>")
//         html = html.replacingOccurrences(of: "## ", with: "<h2>")
//         html = html.replacingOccurrences(of: "# ", with: "<h1>")
        
//         // Code blocks first (before inline code)
//         let codeBlockPattern = "```([\\s\\S]*?)```"
//         html = html.replacingOccurrences(
//             of: codeBlockPattern,
//             with: "<pre><code>$1</code></pre>",
//             options: .regularExpression
//         )
        
//         // Inline code
//         let inlineCodePattern = "`([^`]+)`"
//         html = html.replacingOccurrences(
//             of: inlineCodePattern,
//             with: "<code>$1</code>",
//             options: .regularExpression
//         )
        
//         // Bold text
//         let boldPattern = "\\*\\*([^*]+)\\*\\*"
//         html = html.replacingOccurrences(
//             of: boldPattern,
//             with: "<strong>$1</strong>",
//             options: .regularExpression
//         )
        
//         // Italic text
//         let italicPattern = "\\*([^*]+)\\*"
//         html = html.replacingOccurrences(
//             of: italicPattern,
//             with: "<em>$1</em>",
//             options: .regularExpression
//         )
        
//         // Line breaks and paragraphs
//         let paragraphs = html.components(separatedBy: "\n\n")
//         html = paragraphs.map { paragraph in
//             let lines = paragraph.components(separatedBy: "\n")
//             return "<p>" + lines.joined(separator: "<br>") + "</p>"
//         }.joined(separator: "")
        
//         return html
//     }
    
//     private func escapeHTML(_ string: String) -> String {
//         return string
//             .replacingOccurrences(of: "&", with: "&amp;")
//             .replacingOccurrences(of: "<", with: "&lt;")
//             .replacingOccurrences(of: ">", with: "&gt;")
//             .replacingOccurrences(of: "\"", with: "&quot;")
//             .replacingOccurrences(of: "'", with: "&#39;")
//     }
    
//     @MainActor
//     private func measureContentHeight() async {
//         do {
//             let height = try await webPage.callJavaScript(
//                 "document.body.scrollHeight",
//                 arguments: [:]
//             ) as? Double
            
//             if let height = height {
//                 contentHeight = CGFloat(height)
//             }
//         } catch {
//             print("Failed to measure content height: \(error)")
//         }
//     }
// }
