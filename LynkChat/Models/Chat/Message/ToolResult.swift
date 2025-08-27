//
//  ToolResult.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/08/2025.
//

import Foundation

enum ToolResult: Codable {
    case webSearch(SearchResult)
    case scrapeLinks(ScrapeLinksResult)
    case imageGeneration(String) // URL string
    case rag(RAGResponse)
    case processFile(String) // Text content
    case reasoning(String) // Text content
    
    var requiresFollowUp: Bool {
        switch self {
        case .webSearch, .rag:
            return true
        default:
            return false
        }
    }
    
    var textContent: String {
        switch self {
        case .webSearch(let result):
            var text = ""
            if let answer = result.answer {
                text += "Answer: \(answer)\n\n"
            }
            for res in result.results {
                text += "Result:\nURL: \(res.url)\nTitle: \(res.title)\nContent: \(res.content)\n\n"
            }
            return text
        case .scrapeLinks(let result):
            var text = ""
            for item in result.results {
                text += "URL: \(item.url)\nContent: \(item.rawContent)\n\n"
            }
            return text
        case .imageGeneration(_):
            return "Generated Image was shown to user"
        case .rag(let response):
            var text = ""
            for content in response.content {
                text += "Filename: \(content.filename)\nSimilarity: \(content.similarity)\nText: \(content.text)\n\n"
            }
            return text
        case .processFile(let content):
            return "File text content:\n\(content)"
        case .reasoning(let content):
            return "Reasoning:\n\(content)"
        }
    }
}
