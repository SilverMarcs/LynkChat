//
//  FetchURLResult.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/08/2025.
//

import Foundation

struct ScrapeLinksResult: Codable {
    let results: [ScrapeLinksItem]
    
    struct ScrapeLinksItem: Codable {
        let url: String
        let rawContent: String
        let images: [String]
        let favicon: String
    }
}
