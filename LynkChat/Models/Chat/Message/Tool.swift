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
        case .webSearch, .scrapeLinks: .accent
        case .imageGeneration: .mint
        }
    }
    
    // TODO: Implement this
    func resultView(result: String) -> some View {
        Text("Result: \(result)")
    }
    
    // TODO: Implement this
    func callView() -> some View {
        Text("Call View")
    }
}
