//
//  PasteHandler.swift
//  LynkChat
//
//  Created by Zabir Raihan on 12/10/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct PasteHandler: ViewModifier {
    @State private var eventMonitor: Any?
    var chat: Chat
    var isQuickPanel: Bool // Simple flag to identify if this is the quick panel handler
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    // Only process if this is the appropriate handler for the active window
                    guard shouldHandlePaste() else {
                        return event
                    }
                    
                    if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                        if handleCommandV() {
                            return nil // Consume the event if we handled it
                        }
                    }
                    return event
                }
            }
            .onDisappear {
                if let monitor = self.eventMonitor {
                    NSEvent.removeMonitor(monitor)
                }
            }
    }
    
    private func shouldHandlePaste() -> Bool {
        // Get the key window's identifier
        let keyWindowIdentifier = NSApp.keyWindow?.identifier?.rawValue
        
        // For quick panel handler, only handle paste if the quick panel is key
        if isQuickPanel {
            return keyWindowIdentifier == "quickPanel"
        } else {
            // For main window handler, only handle paste if the main window is key
            // (and not the quick panel)
            return keyWindowIdentifier != "quickPanel"
        }
    }


    private func handleCommandV() -> Bool {
        guard let pasteboardItems = NSPasteboard.general.pasteboardItems else {
            return false
        }

        let handledTypes: Set<NSPasteboard.PasteboardType> = [.fileURL, .png, .tiff, .pdf]
        var handledFiles = false
        var containsText = false

        for item in pasteboardItems {
            if Set(item.types).intersection(handledTypes).isEmpty == false {
                chat.inputManager.handlePaste(pasteboardItem: item, supportedTypes: chat.config.model.supportedTypes)
                handledFiles = true
            } else if item.types.contains(.string) {
                containsText = true
            }
        }

        return handledFiles || (containsText ? false : false)
    }
}

extension View {
    func pasteHandler(chat: Chat, isQuickPanel: Bool = false) -> some View {
        self.modifier(PasteHandler(chat: chat, isQuickPanel: isQuickPanel))
    }
}
