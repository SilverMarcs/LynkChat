//
//  SearchResult.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let index: Int
    
    var displayDomain: String {
        if let host = URL(string: url)?.host {
            return host // Return the full host instead of just the domain
        }
        return ""
    }
    
    var faviconURL: String {
        if let host = URL(string: url)?.host {
            let components = host.components(separatedBy: ".")
            if components.count >= 2 {
                // Create a proper range from the second-to-last element to the end
                let mainDomain = components[(components.count - 2)..<components.count].joined(separator: ".")
                return "https://\(mainDomain)/favicon.ico"
            }
        }
        return ""
    }
}

struct SearchResultView: View {
    let searchString: String
    @State private var results: [SearchResult] = []
    
    var body: some View {
        HStack {
            ForEach(results.prefix(4)) { result in
                Link(destination: URL(string: result.url) ?? URL(string: "https://github.com")!) {
                    GroupBox {
                        VStack(alignment: .leading) {
                            Text(result.title)
                                .font(.headline)
                                .lineLimit(1)
                            
                            HStack(spacing: 4) {
                                // Favicon
                                AsyncImage(url: URL(string: result.faviconURL)) { image in
                                    image
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                } placeholder: {
                                    Image(systemName: "globe")
                                        .frame(width: 16, height: 16)
                                }
                                
                                Text(result.displayDomain)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 4)
                        .frame(width: 155, height: 44, alignment: .leading)
                    }
                    .groupBoxStyle(PlatformGroupBoxStyle())
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
    SearchResultView(searchString: .mockGoogleSearch)
    .frame(width: 600, height: 400)

}
