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
    
    var iconName: String {
        switch self {
        case .webSearch, .scrapeLinks: "network"
        case .imageGeneration: "photo"
        }
    }
    
    var color: Color {
        switch self {
        case .webSearch, .scrapeLinks: .blue
        case .imageGeneration: .indigo
        }
    }
}
