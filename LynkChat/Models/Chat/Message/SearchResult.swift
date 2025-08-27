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
    let results: [Result]
    
    struct Result: Codable {
        let title: String
        let url: String
        let favicon: String
        let content: String
    }
}
