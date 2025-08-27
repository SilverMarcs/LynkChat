//
//  RAGResponse.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/08/2025.
//

import Foundation

struct RAGResult: Codable {
    let count: Int
    let content: [RAGResultItem]
    
    struct RAGResultItem: Codable {
        let text: String
        let similarity: Double
        let filename: String
        let fileExtension: String
    }
}
