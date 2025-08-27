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
    
    var body: some View {
        if let searchResult = searchResult {
            FlowLayout {
                ForEach(searchResult.results, id: \.url) { result in
                    SearchResultPillView(searchResult: result)
                }
            }
        } else {
            FlowLayout {
                ForEach(0..<5, id: \.self) { _ in
                    SearchResultPillView(searchResult: SearchResult.SearchResultItem(
                        url: "this.is.not.valid",
                        title: "Loading Big",
                        favicon: "",
                        content: "",
                    ))
                    .shimmer(when: true)
                }
            }
        }
    }
}

struct SearchResultPillView: View {
    let searchResult: SearchResult.SearchResultItem
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button {
            if let url = URL(string: searchResult.url) {
                openURL(url)
            }
        } label: {
            Label {
                Text(searchResult.title.prefix(20) + (searchResult.title.count > 20 ? "..." : ""))
                    .lineLimit(1)
            } icon: {
                AsyncImage(url: !searchResult.favicon.isEmpty ? URL(string: searchResult.favicon) : nil) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Image(systemName: "network")
                        .foregroundStyle(.accent)
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
