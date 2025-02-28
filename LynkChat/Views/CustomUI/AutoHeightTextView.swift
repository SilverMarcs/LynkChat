////
////  AutoHeightTextView.swift
////  LynkChat
////
////  Created by Zabir Raihan on 20/12/2024.
////
//

import SwiftUI

import SwiftUI

struct AutoHeightTextView: NSViewRepresentable {
    let text: String
    @Binding var height: CGFloat
    @ObservedObject private var config = AppConfig.shared
    
    // Add a container width parameter to know when to wrap
    var containerWidth: CGFloat? = nil
    
    typealias NSViewType = CustomTextView
    
    static func == (lhs: AutoHeightTextView, rhs: AutoHeightTextView) -> Bool {
        return lhs.text == rhs.text && lhs.height == rhs.height && lhs.config.fontSize == rhs.config.fontSize
    }
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textContainer?.lineFragmentPadding = 0
        
        // Set up wrapping behavior
        textView.isHorizontallyResizable = false  // Don't allow horizontal resizing
        textView.isVerticallyResizable = true     // Allow vertical resizing
        textView.autoresizingMask = [.width]      // Resize width with container
        textView.textContainer?.widthTracksTextView = true
        
        textView.delegate = context.coordinator
        updateFontSize(textView)
        return textView
    }
    
    func updateNSView(_ nsView: CustomTextView, context: Context) {
        nsView.string = text
        updateFontSize(nsView)
        
        // Set the maximum width for wrapping
        if let containerWidth = containerWidth {
            // Use container width for wrapping, minus some padding
            let maxWidth = max(100, containerWidth - 20) // Minimum width of 100, with some padding
            nsView.textContainer?.size = NSSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
            nsView.maxWidth = maxWidth
        } else {
            // If no container width provided, calculate based on content
            let estimatedWidth = estimateTextWidth(text: text, font: NSFont.systemFont(ofSize: config.fontSize))
            let maxWidth = min(estimatedWidth, 600) // Cap at reasonable max width
            nsView.textContainer?.size = NSSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
            nsView.maxWidth = maxWidth
        }
        
        DispatchQueue.main.async {
            if let layoutManager = nsView.layoutManager {
                layoutManager.ensureLayout(for: nsView.textContainer!)
                let height = layoutManager.usedRect(for: nsView.textContainer!).height
                self.height = height
                nsView.invalidateIntrinsicContentSize()
            }
        }
    }
    
    // Helper function to estimate text width
    private func estimateTextWidth(text: String, font: NSFont) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).boundingRect(
            with: NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: attributes
        ).size
        
        return ceil(size.width)
    }
    
    private func updateFontSize(_ textView: NSTextView) {
        let font = NSFont.systemFont(ofSize: config.fontSize)
        textView.font = font
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        
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
            guard let textView = notification.object as? CustomTextView else { return }
            if let layoutManager = textView.layoutManager {
                layoutManager.ensureLayout(for: textView.textContainer!)
                let height = layoutManager.usedRect(for: textView.textContainer!).height
                parent.height = height
                textView.invalidateIntrinsicContentSize()
            }
        }
    }
}

class CustomTextView: NSTextView {
    var maxWidth: CGFloat = 0
    
    override var intrinsicContentSize: NSSize {
        guard let layoutManager = self.layoutManager, let textContainer = self.textContainer else {
            return super.intrinsicContentSize
        }
        
        layoutManager.ensureLayout(for: textContainer)
        let usedRect = layoutManager.usedRect(for: textContainer)
        let height = ceil(usedRect.height)
        
        // Use the actual content width, but cap at maxWidth
        let contentWidth = ceil(usedRect.width)
        let width = maxWidth > 0 ? min(contentWidth, maxWidth) : contentWidth
        
        return NSSize(width: width, height: height)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        superview?.rightMouseDown(with: event)
    }
}
