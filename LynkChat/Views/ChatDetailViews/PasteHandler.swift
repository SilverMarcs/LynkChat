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
    @State private var hostingView: NSView?
    var chat: Chat
    var isQuickPanel: Bool // Simple flag to identify if this is the quick panel handler
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                        if shouldHandlePaste() && handleCommandV() {
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
            .background(HostingViewFinder(hostingView: $hostingView))
    }

    private func shouldHandlePaste() -> Bool {
        guard let keyWindow = NSApp.keyWindow else {
            return false
        }

        // For quick panel handler, only handle paste if the quick panel is key
        if isQuickPanel {
            return keyWindow.identifier?.rawValue == "quickPanel"
        } else {
            // For regular windows, check if this view's window is the key window
            guard let hostingView = hostingView, let viewWindow = unsafe hostingView.window else {
                return false
            }

            return viewWindow == keyWindow
        }
    }

    private func handleCommandV() -> Bool {
        guard let pasteboardItems = NSPasteboard.general.pasteboardItems else {
            return false
        }

        let handledTypes: Set<NSPasteboard.PasteboardType> = [.fileURL, .png, .tiff, .pdf]
        var handled = false

        for item in pasteboardItems {
            // Files and images — always handle
            if Set(item.types).intersection(handledTypes).isEmpty == false {
                chat.inputManager.handlePaste(pasteboardItem: item, supportedTypes: chat.config.model.supportedTypes)
                handled = true
            } else if item.types.contains(.string) {
                // For plain text, only intercept and convert to a .txt attachment when the text is large.
                if let pasted = item.string(forType: .string) {
                    let trimmed = pasted.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.count >= InputManager.Constants.pasteTextToFileThreshold {
                        // Let InputManager decide how to convert the large text into a .txt file
                        chat.inputManager.handlePaste(pasteboardItem: item, supportedTypes: chat.config.model.supportedTypes)
                        handled = true
                    } else {
                        // Small text: do not consume the paste event so the system pastes into the focused text field
                    }
                }
            }
        }

        return handled
    }
}

// Helper to find the NSView hosting this SwiftUI view
struct HostingViewFinder: NSViewRepresentable {
    @Binding var hostingView: NSView?
    
    class Coordinator {
        var hostingView: Binding<NSView?>
        
        init(hostingView: Binding<NSView?>) {
            self.hostingView = hostingView
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(hostingView: $hostingView)
    }
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            context.coordinator.hostingView.wrappedValue = view
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Don't update the hostingView here to avoid the warning
    }
}

extension View {
    func pasteHandler(chat: Chat, isQuickPanel: Bool = false) -> some View {
        self.modifier(PasteHandler(chat: chat, isQuickPanel: isQuickPanel))
    }
}
