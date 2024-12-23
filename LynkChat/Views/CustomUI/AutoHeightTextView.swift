////
////  AutoHeightTextView.swift
////  LynkChat
////
////  Created by Zabir Raihan on 20/12/2024.
////
//

import SwiftUI

struct AutoHeightTextView: NSViewRepresentable {
    let text: String
    @Binding var height: CGFloat
    @ObservedObject private var config = AppConfig.shared  // Add this
    
    typealias NSViewType = CustomTextView
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textContainer?.lineFragmentPadding = 0
        textView.textContainer?.widthTracksTextView = true
        textView.delegate = context.coordinator
        updateFontSize(textView)  // Set initial font size
        return textView
    }
    
    func updateNSView(_ nsView: CustomTextView, context: Context) {
        nsView.string = text
        updateFontSize(nsView)  // Update font size when it changes
        
        DispatchQueue.main.async {
            if let layoutManager = nsView.layoutManager {
                layoutManager.ensureLayout(for: nsView.textContainer!)
                let height = layoutManager.usedRect(for: nsView.textContainer!).height
                self.height = height
            }
        }
    }
    
    private func updateFontSize(_ textView: NSTextView) {
        let font = NSFont.systemFont(ofSize: config.fontSize)
        textView.font = font
        
        // Update the default paragraph style with line spacing if needed
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2  // Optional: adjust line spacing
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: NSColor.labelColor
        ]
        
        textView.typingAttributes = attributes
        
        if let storage = textView.textStorage {
            storage.addAttributes(attributes, range: NSRange(location: 0, length: storage.length))
        }
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: AutoHeightTextView
        
        init(_ parent: AutoHeightTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            if let layoutManager = textView.layoutManager {
                layoutManager.ensureLayout(for: textView.textContainer!)
                let height = layoutManager.usedRect(for: textView.textContainer!).height
                parent.height = height
            }
        }
    }
}

class CustomTextView: NSTextView {
    override func rightMouseDown(with event: NSEvent) {
        superview?.rightMouseDown(with: event)
    }
}
