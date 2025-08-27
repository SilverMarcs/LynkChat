//
//  SearchResult.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/01/2025.
//

import SwiftUI

// Main view
struct ToolSearchResultView: View {
    let searchResult: SearchResult?
    @ObservedObject var config = AppConfig.shared
    
    init(searchResult: SearchResult?) {
        self.searchResult = searchResult
    }
    
    var body: some View {
        if let searchResult = searchResult {
            FlowLayout {
                ForEach(searchResult.results, id: \.url) { result in
                    SearchResultPillView(searchResult: result)
                }
            }
            
            if let answer = searchResult.answer {
                Text(answer)
                    .textSelection(.enabled)
                    .lineSpacing(4)
                    .font(.system(size: config.fontSize + 0.5))
            }
        } else {
            FlowLayout {
                ForEach(0..<5, id: \.self) { _ in
                    SearchResultPillView(searchResult: SearchResult.Result(
                        url: "https://example.com",
                        title: "Loading...",
                        favicon: "",
                        content: "",
                    ))
                    .disabled(true)
                    .shimmer(when: true)
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
