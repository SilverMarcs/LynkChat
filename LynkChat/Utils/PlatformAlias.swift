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
typealias PlatformViewRepresentable = NSViewRepresentable
#else
typealias PlatformColor = UIColor
typealias PlatformFont = UIFont
typealias PlatformView = UIView
typealias PlatformViewRepresentable = UIViewRepresentable
#endif
