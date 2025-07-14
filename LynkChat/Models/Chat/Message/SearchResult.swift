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
    let images: [String]  // Changed from [ImageResult]
    let results: [Result]
    
    struct Result: Codable {
        let title: String
        let url: String
        let content: String
        let score: Double
    }
}
