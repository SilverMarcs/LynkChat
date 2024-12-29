//
//  Tool.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import Foundation
import SwiftUI

enum Tool: String, CaseIterable, Codable {
    case webSearch
    case scrapeLinks
    case imageGeneration
    
    var title: String {
        switch self {
        case .webSearch: "Web Search"
        case .scrapeLinks: "Fetch URL"
        case .imageGeneration: "Generate Image"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .webSearch: "Web"
        case .scrapeLinks: "URL"
        case .imageGeneration: "Image"
        }
    }
    
    var iconName: String {
        switch self {
        case .webSearch, .scrapeLinks: "network"
        case .imageGeneration: "photo.on.rectangle"
        }
    }
    
    var color: Color {
        switch self {
        case .webSearch, .scrapeLinks: .cyan
        case .imageGeneration: .mint
        }
    }
    
    // TODO: Implement this
    func argsView(_ args: String) -> some View {
        Text("Args: \(args)")
    }
}
