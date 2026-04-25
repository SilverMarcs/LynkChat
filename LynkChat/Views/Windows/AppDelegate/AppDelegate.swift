//
//  AppDelegate.swift
//  LynkChat
//
//  Created by Zabir Raihan on 03/10/2024.
//

import Foundation
import UniformTypeIdentifiers

#if os(iOS)
import UIKit

extension Notification.Name {
    static let sharedContentReceived = Notification.Name("sharedContentReceived")
    static let sharedImagesReceived = Notification.Name("sharedImagesReceived")
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme == "lynkchat" && url.host == "share" {
            checkForSharedContent()
            return true
        }
        return false
    }
    
    private func checkForSharedContent() {
        guard let ud = UserDefaults(suiteName: "group.com.temporary.lynkchat") else { return }

        let payload = ud.string(forKey: "sharedContent")
        let imagePaths = ud.stringArray(forKey: "sharedImagePaths")

        if let payload, !payload.isEmpty {
            NotificationCenter.default.post(
                name: .sharedContentReceived,
                object: nil,
                userInfo: ["payload": payload]
            )
        }

        if let imagePaths, !imagePaths.isEmpty {
            NotificationCenter.default.post(
                name: .sharedImagesReceived,
                object: nil,
                userInfo: ["imagePaths": imagePaths]
            )
        }

        // Clear after handling
        ud.removeObject(forKey: "sharedContent")
        ud.removeObject(forKey: "sharedImagePaths")
        ud.removeObject(forKey: "sharedContentDate")
        ud.synchronize()
    }
}


class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        
        // Check if opened from share extension
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(urlContext.url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleURL(url)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    private func handleURL(_ url: URL) {
        // Check if it's from the share extension
        if url.scheme == "lynkchat" && url.host == "share" {
            checkForSharedContent()
        }
    }
    
    private func checkForSharedContent() {
        guard let ud = UserDefaults(suiteName: "group.com.temporary.lynkchat") else { return }

        let payload = ud.string(forKey: "sharedContent")
        let imagePaths = ud.stringArray(forKey: "sharedImagePaths")

        if let payload, !payload.isEmpty {
            NotificationCenter.default.post(
                name: .sharedContentReceived,
                object: nil,
                userInfo: ["payload": payload]
            )
        }

        if let imagePaths, !imagePaths.isEmpty {
            NotificationCenter.default.post(
                name: .sharedImagesReceived,
                object: nil,
                userInfo: ["imagePaths": imagePaths]
            )
        }

        // Clear after handling
        ud.removeObject(forKey: "sharedContent")
        ud.removeObject(forKey: "sharedImagePaths")
        ud.removeObject(forKey: "sharedContentDate")
        ud.synchronize()
    }
}
#endif

#if os(macOS)
import AppKit

class MacAppDelegate: NSObject, NSApplicationDelegate {
    private var windowObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Observe window changes to automatically hide/show from dock
        windowObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateDockVisibility()
        }

        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Delay slightly to allow window count to update
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.updateDockVisibility()
            }
        }

        // Initial check
        updateDockVisibility()
    }

    deinit {
        if let observer = windowObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func updateDockVisibility() {
        let hideWhenClosed = UserDefaults.standard.bool(forKey: "hideDockIconWhenWindowClosed")

        let windows = NSApp.windows.filter { window in
            // Count only regular windows, not panels (like the quick panel)
            // and not hidden/minimized windows
            window.isVisible &&
            !window.isKind(of: NSPanel.self) &&
            window.title != "" &&
            window.identifier?.rawValue != "quickPanel"
        }

        if windows.isEmpty && hideWhenClosed {
            NSApp.setActivationPolicy(.accessory)
        } else {
            if NSApp.activationPolicy() != .regular {
                NSApp.setActivationPolicy(.regular)
            }
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // When clicking the dock icon (if visible) and no windows are open,
        // you could optionally open a window or show the quick panel
        if !flag {
            // No visible windows - could show quick panel or do nothing
            // For now, just ensure we're visible in dock when reopening
            NSApp.setActivationPolicy(.regular)
        }
        return true
    }
}
#endif

