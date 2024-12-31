//
//  Tool.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import Foundation
import SwiftUI

enum Tool: String, CaseIterable, Codable {
    case webSearch
    case scrapeLinks
    case imageGeneration
    case transcribe
    
    var title: String {
        switch self {
        case .webSearch: "Web Search"
        case .scrapeLinks: "Fetch URL"
        case .imageGeneration: "Generate Image"
        case .transcribe: "Transcribe"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .webSearch: "Web"
        case .scrapeLinks: "URL"
        case .imageGeneration: "Image"
        case .transcribe: "Audio"
        }
    }
    
    var iconName: String {
        switch self {
        case .webSearch, .scrapeLinks: "network"
        case .imageGeneration: "photo.stack"
        case .transcribe: "waveform"
        }
    }
    
    var color: Color {
        switch self {
        case .webSearch, .scrapeLinks: .cyan
        case .imageGeneration: .mint
        case .transcribe: .orange
        }
    }
    
    var toolPrompt: String {
        switch self {
        case .webSearch: 
            "If the user requests for information beyond your knowledge cutoff, current events, about some term you are totally unfamiliar with (it might be new), you may use the web search tool to find the information on the internet. BUt do not use this too to scrape links. Use the scrapeLinks tool for that. In many cases, a simple call of teh web search tool may be sufficient to find the information using the tools' short snippets. However, if the user requests for more detailed information or if the snippets and website titles were not sufficient to properly answer the user's query, you may use the scrapeLinks tool to look into some of the urls that were in the search results. If you used context from a certain snippet of a certain website, format the reference properly using markdwon at the end of your response. For referemnces, use a short display text instead of the website's entire title. Regardless, always prioritise your existing knwoledge from your training. Do not use the tool to look up information that you already know unless the user specifically asks for it."
        case .scrapeLinks:
            "If links are provided by the user, you may use the scrapeLinks tool to fetch the contents of the URLs. The tool will fetch the contents of the URLs and return the text. Do not come up with Urls on your own. Only use the scrapeLinks tool if the user provides the links or if there are urls available in the chat from a prior web search tool invocation. The tool may often fail to retrieve the contents of the URL, in which case you should inform the user that you were unable to retrieve the contents of the URL. Moreover, content scraped from links may contain a lot of extra stuff such as website footers or social links, etc. Ignore them."
        case .imageGeneration:
            "If a user desires to generate an image or want to see something, you may use the imageGeneration tool that uses AI for image generation. Craft a text description related to the user's request and pass to the Image gen AI but do not enahnce it so mudh that relevance to the user's request is lost. Do not enhance if the user specifically provides a prompt of their own"
        case .transcribe:
            "If the user sends key of a file.io link, you may use the transcribe tool to convert the audio by passing the key to the transcribe tool. the tool will on its own retrieve the audio file and convert it form audio to text."
        }
    }
}
