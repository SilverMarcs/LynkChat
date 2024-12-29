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
            // Split by dots and take the last two parts (excluding TLD)
            let parts = host.components(separatedBy: ".")
            if parts.count >= 2 {
                return parts[parts.count - 2]
            }
            return host
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
                            
                            Text(result.displayDomain)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 150, alignment: .leading)
                        .padding(5)
                    }
                    .groupBoxStyle(PlatformGroupBoxStyle())
                }
            }
        }
        .task {
            Task {
                await parseResults()
            }
        }
    }
    
    // TODO: must make async
    private func parseResults() async {
        let entries = searchString.components(separatedBy: "\n\n")
        var parsedResults: [SearchResult] = []
        
        for entry in entries {
            let lines = entry.components(separatedBy: "\n")
            if lines.count >= 3 {
                let titleLine = lines[0]
                let urlLine = lines[1]
                
                if let index = titleLine.firstMatch(of: /\[(\d+)\]/)?.1,
                   let indexNum = Int(index) {
                    let title = titleLine.replacingOccurrences(of: "Result: [\\d+] ", with: "", options: .regularExpression)
                    let url = urlLine.replacingOccurrences(of: "URL: ", with: "")
                    
                    parsedResults.append(SearchResult(title: title, url: url, index: indexNum))
                }
            }
        }
        
        // Limit to first 4 results
        self.results = Array(parsedResults.prefix(4))
        print("Number of results: \(results.count)")
    }
}

#Preview {
    SearchResultView(searchString: .mockGoogleSearch)
    .frame(width: 600, height: 400)

}
