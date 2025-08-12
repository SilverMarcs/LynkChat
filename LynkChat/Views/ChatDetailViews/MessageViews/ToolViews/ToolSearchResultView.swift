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
    
    @State private var parsedResults: SearchResult?
    
    var body: some View {
        if let searchString {
            if let parsed = try? JSONDecoder().decode(SearchResult.self, from: searchString.data(using: .utf8) ?? Data()) {
                // Show parsed results in horizontal scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(parsed.results, id: \.url) { result in
                            pillContent(text: result.title, url: result.url)
                        }
                    }
                }
            } else {
                Text(searchString)
                    .textSelection(.enabled)
            }
        } else {
            // Placeholder state in horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { _ in
                        pillContent(text: "com.example.com", url: nil)
                    }
                }
            }
        }
    }
    
    private func pillContent(text: String, url: String?) -> some View {
        Link(destination: URL(string: url ?? "") ?? URL(string: "https://www.google.com")!) {
            Label {
                Text(text.prefix(20) + (text.count > 20 ? "..." : ""))
                    .lineLimit(1)
            } icon: {
                if let url = url, let faviconURL = getFaviconURL(from: url) {
                    AsyncImage(url: URL(string: faviconURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                        default:
                            Image(systemName: "network")
                                .frame(width: 15, height: 15)
                                .foregroundStyle(.accent)
                        }
                    }
                } else {
                    Image(systemName: "network")
                        .frame(width: 15, height: 15)
                        .foregroundStyle(.accent)
                }
            }
            .shimmer(when: searchString == nil)
            .disabled(searchString == nil)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
    }
    
    private func getFaviconURL(from url: String) -> String? {
        guard let host = URL(string: url)?.host else { return nil }
        let components = host.components(separatedBy: ".")
        if components.count >= 2 {
            let mainDomain = components[(components.count - 2)..<components.count].joined(separator: ".")
            return "https://\(mainDomain)/favicon.ico"
        }
        return nil
    }
    
    var padding: CGFloat {
        #if os(macOS)
        return 6
        #else
        return 7
        #endif
    }
}
