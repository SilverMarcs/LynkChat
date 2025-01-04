//
//  ToolSearchView.swift.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

// TODO: make building this view async?
struct ToolSearchView: View {
    let searchString: String
    @State private var results: [SearchResult] = []
    @State private var showingPopover = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(results) { result in
                    Link(destination: URL(string: result.url) ?? URL(string: "https://github.com")!) {
                        HStack(spacing: 6) {
                            AsyncImage(url: URL(string: result.faviconURL)) { image in
                                image
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            } placeholder: {
                                Image(systemName: "globe")
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(result.displayDomain)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, padding)
                        .padding(.vertical, padding - 2)
                        .background(.quinary.opacity(0.8))
                        .cornerRadius(10)
                        #if os(macOS)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.quaternary, lineWidth: 1)
                        }
                        #endif
                    }
                    .buttonStyle(.plain)
                }
            
                Button {
                    showingPopover = true
                } label: {
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                    .padding(6)
                    .padding(.horizontal, 1)
                    .background(.quinary)
                    .cornerRadius(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.quaternary, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingPopover) {
                    SearchResultsPopover(results: results)
                }
            }
        }
        .task {
            await parseResults()
        }
    }
    
    var padding: CGFloat {
        #if os(macOS)
        return 5
        #else
        return 7
        #endif
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
    .frame(width: 400, height: 400)

}
