//
//  Double++.swift
//  LynkChat
//
//  Created by Zabir Raihan on 19/10/2025.
//

import SwiftUI

extension Double {
    #if os(macOS)
    static let defaultFontSize: Double = 13
    #else
    static let defaultFontSize: Double = 17
    #endif
}
