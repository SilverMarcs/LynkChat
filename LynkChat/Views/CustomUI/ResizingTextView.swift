//
//  ResizingTextView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 20/12/2024.
//

#if os(macOS)
import SwiftUI

struct ResizingTextView: NSViewRepresentable {
    let text: String
    @Binding var height: CGFloat

    func makeNSView(context: Context) -> NSTextView {
        let textView = CustomTextView()  // Use custom subclass instead of NSTextView
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.textColor = NSColor.textColor
        textView.font = NSFont.systemFont(ofSize: 13)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.string = text
        nsView.layoutManager?.ensureLayout(for: nsView.textContainer!)

        if let textContainer = nsView.textContainer, let layoutManager = nsView.layoutManager {
            let usedSize = layoutManager.usedRect(for: textContainer)
            DispatchQueue.main.async {
                self.height = usedSize.height
            }
        }
    }
}

class CustomTextView: NSTextView {
    override func menu(for event: NSEvent) -> NSMenu? {
        // Return nil to prevent showing the text view's context menu
        return nil
    }
}
#endif
