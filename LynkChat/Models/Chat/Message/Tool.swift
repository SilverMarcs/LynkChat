//
//  Tool.swift
//  LynkChat
//
//  Created by Zabir Raihan on 29/12/2024.
//

import Foundation
import SwiftUI

enum Tool: String, Identifiable, CaseIterable, Codable {
    case webSearch
    case scrapeLinks
    case imageGeneration
    case transcribe
    
    var  id: Self { self }
    
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
        case .webSearch: "network"
        case .scrapeLinks: "link"
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
            "If user request knowledge thats new to you, you may search the web. If you deem its a Simple QNA type query, you can just use the QNA searchType. If it requries more in depth context, such as ways to code something, you may use the moderate searchType. This moderate searchType would most likley be sufficient help to answer most of the user's query. For research related topics where the user speicifcally wanted more than just a simple answer and asked to check multiple searches, you may use thorough searchType. If a particular searchType proider unsatsifactory results, feel free to try the next most apporpiate searchType. If the thoroigh type was used and th econtent property did not hanswer the question properly, use the tool for scraping looks to check any of the search results for additional information. Priorities usign moderate searchtype unless any o fthe oteher two types are genuinely more apporpiate."
        case .scrapeLinks:
            "If links are provided by the user, you may use the scrapeLinks tool to fetch the contents of the URLs. The tool will fetch the contents of the URLs and return the text. Do not come up with Urls on your own. Only use the scrapeLinks tool if the user provides links in their query or if there are urls available in the chat from a prior web search tool invocation/"
        case .imageGeneration:
            "If a user desires to generate an image or want to see something, you may use the imageGeneration tool that uses AI for image generation. Craft a text description related to the user's request and pass to the Image gen AI but do not enahnce it so mudh that relevance to the user's request is lost. Do not enhance if the user specifically provides a prompt of their own. Do not reference links generated as part of image generation tool usage."
        case .transcribe:
            "If the user sends key of a file.io link, you may use the transcribe tool to convert the audio by passing the key to the transcribe tool. the tool will on its own retrieve the audio file and convert it form audio to text. Never mention to the user anything about the FileIO key, if needed, just acknowledge an audio file was attached but the whole process for FileIO happnes internally and should not be exposed to user."
        }
    }
}
