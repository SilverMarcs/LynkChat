//
//  NSAppDelegate.swift
//  LynkChat
//
//  Created by Zabir Raihan on 22/06/2025.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    static let shared = AppDelegate()
    weak var chatVM: ChatVM?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // App finished launching
    }
}
