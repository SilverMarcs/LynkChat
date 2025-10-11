//
//  AppIconMenu.swift
//  LynkChat
//
//  Created by Zabir Raihan on 03/10/2024.
//

import UIKit

extension Notification.Name {
    static let sharedContentReceived = Notification.Name("sharedContentReceived")
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
        guard let payload = ud.string(forKey: "sharedContent"), !payload.isEmpty else {
            return
        }

        // Post notification with the payload
        NotificationCenter.default.post(
            name: .sharedContentReceived,
            object: nil,
            userInfo: ["payload": payload]
        )

        // Clear after handling
        ud.removeObject(forKey: "sharedContent")
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
        guard let payload = ud.string(forKey: "sharedContent"), !payload.isEmpty else {
            return
        }

        // Post notification with the payload
        NotificationCenter.default.post(
            name: .sharedContentReceived,
            object: nil,
            userInfo: ["payload": payload]
        )

        // Clear after handling
        ud.removeObject(forKey: "sharedContent")
        ud.removeObject(forKey: "sharedContentDate")
        ud.synchronize()
    }
}
