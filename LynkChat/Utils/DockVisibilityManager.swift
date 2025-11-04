//
//  DockVisibilityManager.swift
//  LynkChat
//
//  Created by Codex on 2025-11-04.
//

import Foundation

#if os(macOS)
import AppKit
import SwiftUI

final class DockVisibilityManager {
    static let shared = DockVisibilityManager()

    private var mainWindowCount: Int = 0 {
        didSet { updateActivationPolicy() }
    }

    private init() {
        // Ensure initial state hides Dock when no main windows
        updateActivationPolicy()
    }

    func registerMainWindowAppear() {
        mainWindowCount = max(0, mainWindowCount + 1)
    }

    func registerMainWindowDisappear() {
        mainWindowCount = max(0, mainWindowCount - 1)
    }

    func updateActivationPolicy() {
        let desired: NSApplication.ActivationPolicy = (mainWindowCount > 0) ? .regular : .accessory
        let app = NSApplication.shared
        if app.activationPolicy() != desired {
            app.setActivationPolicy(desired)
        }
    }
}

struct MainWindowTrackingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear { DockVisibilityManager.shared.registerMainWindowAppear() }
            .onDisappear { DockVisibilityManager.shared.registerMainWindowDisappear() }
    }
}

extension View {
    func trackAsMainWindow() -> some View { modifier(MainWindowTrackingModifier()) }
}

// macOS end
#endif

#if !os(macOS)
import SwiftUI

// No-op on non-macOS platforms so calls compile everywhere
extension View {
    func trackAsMainWindow() -> some View { self }
}
#endif
