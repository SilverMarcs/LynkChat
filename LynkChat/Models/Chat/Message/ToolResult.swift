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
    
    // TODO: us ethsi in toApiMessage
//    var textContent: String {
//        switch self {
//        case .webSearch(let result):
//            result.results.map( {$0. } )
//        case .scrapeLinks(_):
//            <#code#>
//        case .imageGeneration(_):
//            <#code#>
//        case .rag(_):
//            <#code#>
//        case .processFile(_):
//            <#code#>
//        case .reasoning(_):
//            <#code#>
//        }
//    }
}
