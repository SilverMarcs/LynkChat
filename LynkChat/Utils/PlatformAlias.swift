//
//  PlatformAlias.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import SwiftUI

// MARK: - Platform Color
#if os(macOS)
typealias PlatformColor = NSColor
typealias PlatformFont = NSFont
typealias PlatformView = NSView
#else
typealias PlatformColor = UIColor
typealias PlatformFont = UIFont
typealias PlatformView = UIView
#endif
