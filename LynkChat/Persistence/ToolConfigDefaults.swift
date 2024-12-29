//
//  ToolConfigDefaults.swift
//  LynkChat
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

class ToolConfigDefaults: ObservableObject {
    static let shared = ToolConfigDefaults()
    private init() {}
    
    @AppStorage("scrapeLinks") var scrapeLinks: Bool = false
    @AppStorage("webSearch") var webSearch: Bool = false
    @AppStorage("imageGenerate") var imageGenerate: Bool = false
    @AppStorage("transcribe") var transcribe: Bool = false
}
