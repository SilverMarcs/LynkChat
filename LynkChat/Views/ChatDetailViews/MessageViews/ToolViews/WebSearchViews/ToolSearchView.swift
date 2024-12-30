//
//  ToolSearchView.swift.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolSearchView: View {
    let searchString: String
    @State private var results: [SearchResult] = []
    @State private var showingPopover = false
    
    var body: some View {
        HStack(spacing: 8) {
            // First 4 results
            ForEach(results.prefix(4)) { result in
                Link(destination: URL(string: result.url) ?? URL(string: "https://github.com")!) {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(result.title)
                                .font(.subheadline).fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .lineSpacing(0.1)
                            
                            HStack(spacing: 5) {
                                AsyncImage(url: URL(string: result.faviconURL)) { image in
                                    image
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                } placeholder: {
                                    Image(systemName: "globe")
                                        .frame(width: 12, height: 12)
                                }
                                
                                Text(result.displayDomain)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 4)
                        .frame(width: 155, height: 50, alignment: .leading)
                    }
                    .groupBoxStyle(PlatformGroupBoxStyle())
                }
            }
            
            // More button with stacked favicons
            Button {
                showingPopover = true
            } label: {
                GroupBox {
                    VStack {
                        ForEach(Array(results.dropFirst(4).enumerated()), id: \.element.id) { index, result in
                            AsyncImage(url: URL(string: result.faviconURL)) { image in
                                image
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    
                            } placeholder: {
                                Image(systemName: "globe")
                                    .frame(width: 10, height: 10)
                                
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                    .frame(height: 50)
                }
                .groupBoxStyle(PlatformGroupBoxStyle())
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingPopover) {
                List {
                    ForEach(Array(results.dropFirst(4))) { result in
                        Link(destination: URL(string: result.url) ?? URL(string: "https://github.com")!) {
                            HStack(alignment: .top, spacing: 8) {
                                AsyncImage(url: URL(string: result.faviconURL)) { image in
                                    image
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                } placeholder: {
                                    Image(systemName: "globe")
                                        .frame(width: 16, height: 16)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(result.title)
                                        .font(.headline)
                                        .lineLimit(2)
                                    
                                    Text(result.displayDomain)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
        .task {
            await parseResults()
        }
    }
    
    // TODO: must make async
    private func parseResults() async {
        let entries = searchString.components(separatedBy: "\n\n")
        var parsedResults: [SearchResult] = []
        
        for entry in entries {
            let lines = entry.components(separatedBy: "\n")
            if lines.count >= 3 {
                let titleLine = lines[0].trimmingCharacters(in: .whitespaces)
                let urlLine = lines[1].trimmingCharacters(in: .whitespaces)
                
                if let index = titleLine.firstMatch(of: /\[(\d+)\]/)?.1,
                   let indexNum = Int(index) {
                    // Remove the [index] prefix and trim whitespace
                    let title = titleLine.replacingOccurrences(of: "\\[\\d+\\]\\s*", with: "", options: .regularExpression)
                                       .trimmingCharacters(in: .whitespaces)
                    let url = urlLine.replacingOccurrences(of: "URL: ", with: "")
                                    .trimmingCharacters(in: .whitespaces)
                    
                    parsedResults.append(SearchResult(title: title, url: url, index: indexNum))
                }
            }
        }
        
        self.results = parsedResults
    }
}



#Preview {
    ToolSearchView(searchString: .mockGoogleSearch)
    .frame(width: 800, height: 400)

}
