//
//  Tool.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import Foundation
import SwiftUI

enum Tool: String, Identifiable, CaseIterable, Codable, Sendable {
    case webSearch
    case scrapeLinks
    case imageGeneration
    case rag
    
    case processFile
    case reasoning
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .webSearch: "Web Search"
        case .scrapeLinks: "Fetch URL"
        case .imageGeneration: "Generate Image"
        case .rag: "RAG"
        case .processFile: "File Analysis"
        case .reasoning: "Reasoning"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .webSearch: "Web"
        case .scrapeLinks: "URL"
        case .imageGeneration: "Image"
        case .rag: "RAG"
        case .processFile: "File"
        case .reasoning: "Think"
        }
    }
    
    var iconName: String {
        switch self {
        case .webSearch: "network"
        case .scrapeLinks: "link"
        case .imageGeneration: "photo.stack"
        case .rag: "circle.hexagongrid"
        case .processFile: "doc.text"
        case .reasoning: "circle.hexagonpath"
        }
    }
    
    var color: Color {
        switch self {
        case .webSearch, .scrapeLinks: .cyan
        case .imageGeneration: .mint
        case .rag: .blue
        case .processFile: .purple
        case .reasoning: .orange
        }
    }
    
    var description: String {
        switch self {
        case .webSearch:
            "Browse the web or check URLs for up-to-date information."
        case .scrapeLinks, .processFile:
            "Fetch the contents of a URL"
        case .rag:
            "Retrieve data from your documents"
        case .imageGeneration:
            "Generate an image based on a text description"
        case .reasoning:
            "Use advanced reasoning capabilities for complex problem solving"
        }
    }
    
    var toolPrompt: String {
        switch self {
        case .webSearch: 
            "If user request knowledge thats new to you, you may search the web. If this tool was used and the content property did not hanswer the question properly, use the tool for scraping links to check any of the search results for additional information."
        case .scrapeLinks:
            "If links are provided by the user, you may use the scrapeLinks tool to fetch the contents of the URLs. The tool will fetch the contents of the URLs and return the text. Do not come up with Urls on your own. Only use the scrapeLinks tool if the user provides links in their query or if there are urls available in the chat from a prior web search tool invocation. If a link or mor eare provided in user's messages, u should use this tool to scrape its contents if appropriate."
        case .imageGeneration:
            "If a user desires to generate an image or want to see something, you may use the imageGeneration tool that uses AI for image generation. Craft a text description related to the user's request and pass to the Image gen AI but do not enahnce it so mudh that relevance to the user's request is lost. Do not enhance if the user specifically provides a prompt of their own. Do not reference links generated as part of image generation tool usage. Dont provide links for images in chat, it will be provided by tool anyway"
        case .rag:
            "If user asks for personalised data or data that you don't think will be available on the internet, you may use this tool to retrieve related content. "
        case .processFile:
            "File Analysis"
        case .reasoning:
            "Reasoning"
        }
    }
}
