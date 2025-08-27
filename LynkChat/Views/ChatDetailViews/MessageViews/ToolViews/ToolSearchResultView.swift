//
//  SearchResult.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/01/2025.
//

import SwiftUI

// Main view
struct ToolSearchResultView: View {
    let searchString: String?
    @ObservedObject var config = AppConfig.shared
    
    private let parsedResults: SearchResult?
    
    init(searchString: String?) {
        self.searchString = searchString
        
        // Parse once during initialization
        if let searchString = searchString,
           let data = searchString.data(using: .utf8) {
            self.parsedResults = try? JSONDecoder().decode(SearchResult.self, from: data)
        } else {
            self.parsedResults = nil
        }
    }
    
    var body: some View {
        if let searchString {
            if let parsed = parsedResults {
                // Show parsed results in horizontal scroll
                FlowLayout {
                    ForEach(parsed.results, id: \.url) { result in
                        SearchResultPillView(searchResult: result)
                    }
                }
            } else {
                Text(searchString)
                    .textSelection(.enabled)
                    .lineSpacing(4)
                    .font(.system(size: config.fontSize + 0.5))
            }
        } else {
            // Placeholder state in horizontal scroll
            FlowLayout {
                ForEach(0..<5, id: \.self) { _ in
                    SearchResultPillView(searchResult: SearchResult.Result(
                        title: "Loading...",
                        url: "https://example.com",
                        favicon: "",
                        content: "",
                    ))
                    .disabled(searchString == nil)
                }
            }
        }
    }
}

struct SearchResultPillView: View {
    let searchResult: SearchResult.Result
    
    var body: some View {
        Link(destination: URL(string: searchResult.url) ?? URL(string: "https://www.google.com")!) {
            Label {
                Text(searchResult.title.prefix(20) + (searchResult.title.count > 20 ? "..." : ""))
                    .lineLimit(1)
            } icon: {
                Group {
                    if !searchResult.favicon.isEmpty, let faviconURL = URL(string: searchResult.favicon) {
                        AsyncImage(url: faviconURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            default:
                                Image(systemName: "network")
                                    .foregroundStyle(.accent)
                            }
                        }
                    } else {
                        Image(systemName: "network")
                            .foregroundStyle(.accent)
                    }
                }
                .frame(width: iconDimensions, height: iconDimensions)
            }
            #if !os(macOS)
            .labelStyle(.iconOnly)
            #endif
            .shimmer(when: searchResult.content == "Loading")
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
    }
    
    private var iconDimensions: CGFloat {
        #if os(macOS)
        15
        #else
        20
        #endif
    }
}
