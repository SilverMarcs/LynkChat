//
//  ImagePasteHandler.swift
//  LynkChat
//
//  Mirrors chat paste handling, scoped for image input.
//

import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct ImagePasteHandler: ViewModifier {
    @State private var eventMonitor: Any?
    @State private var hostingView: NSView?
    var session: ImageSession

    func body(content: Content) -> some View {
        content
            .onAppear {
                self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                        if shouldHandlePaste(), handleCommandV() {
                            return nil // consume event
                        }
                    }
                    return event
                }
            }
            .onDisappear {
                if let monitor = self.eventMonitor { NSEvent.removeMonitor(monitor) }
            }
            .background(HostingViewFinder(hostingView: $hostingView))
    }

    private func shouldHandlePaste() -> Bool {
        guard let keyWindow = NSApp.keyWindow else { return false }
        guard let hostingView = hostingView, let viewWindow = unsafe hostingView.window else { return false }
        return viewWindow == keyWindow
    }

    private func handleCommandV() -> Bool {
        guard let items = NSPasteboard.general.pasteboardItems else { return false }
        var handled = false

        for item in items {
            // Prefer file URLs that point to images
            if item.types.contains(.fileURL),
               let data = item.data(forType: .fileURL),
               let urlString = String(data: data, encoding: .utf8),
               let url = URL(string: urlString) {
                if let imageData = tryLoadImageData(from: url) {
                    session.inputImages = [imageData]
                    handled = true
                }
            } else if let imageData = item.data(forType: .png) ?? item.data(forType: .tiff) {
                // Direct image data from pasteboard
                session.inputImages = [imageData]
                handled = true
            }

            if handled { break }
        }

        return handled
    }

    private func tryLoadImageData(from url: URL) -> Data? {
        // Validate by type when possible
        if let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType,
           type.conforms(to: .image) {
            return try? Data(contentsOf: url)
        }
        // Fallback: attempt to read and see if NSImage can decode
        if let data = try? Data(contentsOf: url), NSImage(data: data) != nil {
            return data
        }
        return nil
    }
}

extension View {
    func imagePasteHandler(session: ImageSession) -> some View {
        self.modifier(ImagePasteHandler(session: session))
    }
}
