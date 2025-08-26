//
//  RAGResponse.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/08/2025.
//

import Foundation

struct RAGResponse: Codable {
    let count: String
    let content: [RAGContent]
}

struct RAGContent: Codable {
    let text: String
    let similarity: Double
    let filename: String
    let fileExtension: String
}
