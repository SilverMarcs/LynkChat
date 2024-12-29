//
//  Tool.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import Foundation
import SwiftUI

enum Tool: String, CaseIterable, Codable {
    case scrapeUrls
    case webSearch
    case imageGeneration
    
    var title: String {
        switch self {
        case .scrapeUrls: "Fetch URL"
        case .webSearch: "Web Search"
        case .imageGeneration: "Generate Image"
        }
    }
    
    var iconName: String {
        switch self {
        case .scrapeUrls: "link"
        case .webSearch: "magnifyingglass"
        case .imageGeneration: "photo"
        }
    }
    
    var color: Color {
        switch self {
        case .scrapeUrls: .blue
        case .webSearch: .green
        case .imageGeneration: .indigo
        }
    }
}
