//
//  SearchResult.swift
//  LynkChat
//
//  Created by Zabir Raihan on 15/07/2025.
//

import Foundation

struct SearchResult: Codable {
    let query: String
    let answer: String?
    let images: [String]
    let results: [SearchResultItem]
    
    struct SearchResultItem: Codable {
        let url: String
        let title: String
        let favicon: String
        let content: String
    }
}
