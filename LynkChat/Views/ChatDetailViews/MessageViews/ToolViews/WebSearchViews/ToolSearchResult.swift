//
//  SearchResult.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import Foundation

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let index: Int
    
    var displayDomain: String {
        if let host = URL(string: url)?.host {
            return host // Return the full host instead of just the domain
        }
        return ""
    }
    
    var faviconURL: String {
        if let host = URL(string: url)?.host {
            let components = host.components(separatedBy: ".")
            if components.count >= 2 {
                // Create a proper range from the second-to-last element to the end
                let mainDomain = components[(components.count - 2)..<components.count].joined(separator: ".")
                return "https://\(mainDomain)/favicon.ico"
            }
        }
        return ""
    }
}
