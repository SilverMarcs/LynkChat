//
//  SearchResultsPopover.swift
//  LynkChat
//
//  Created by Zabir Raihan on 01/01/2025.
//

import SwiftUI

struct SearchResultsPopover: View {
    let results: [SearchResult]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(results) { result in
                Link(destination: URL(string: result.url) ?? URL(string: "https://github.com")!) {
                    HStack(alignment: .top, spacing: 8) {
                        AsyncImage(url: URL(string: result.faviconURL)) { image in
                            image
                                .resizable()
                                .frame(width: 18, height: 18)
                        } placeholder: {
                            Image(systemName: "globe")
                                .frame(width: 18, height: 18)
                        }
                        .padding(.top, 2)
                        
                        VStack(alignment: .leading) {
                            Text(result.title)
                                .multilineTextAlignment(.leading)
                                .font(.callout).fontWeight(.semibold)
                                .lineLimit(2)
                            
                            Text(result.displayDomain)
                                .font(.caption)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
        .scrollContentBackground(.hidden)
        #if os(macOS)
        .frame(width: 350)
        #endif
    }
}

#Preview {
    SearchResultsPopover(results: [
        SearchResult(title: "SwiftUI by Example", url: "https://swiftbysundell.com", index: 0),
        SearchResult(title: "SwiftUI Tutorials", url: "https://www.hackingwithswift.com/quick-start/swiftui", index: 1),
        SearchResult(title: "SwiftUI Documentation", url: "https://developer.apple.com/documentation/swiftui", index: 2),
        SearchResult(title: "SwiftUI by Example", url: "https://swiftbysundell.com", index: 0),
        SearchResult(title: "SwiftUI Tutorials", url: "https://www.hackingwithswift.com/quick-start/swiftui", index: 1),
        SearchResult(title: "SwiftUI Documentation", url: "https://developer.apple.com/documentation/swiftui", index: 2)
    ])
}
