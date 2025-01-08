//
//  ToolSearchView.swift.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

// TODO: make building this view async?
struct ToolSearchView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let searchString: String?
    @State private var results: [SearchResult] = Array(repeating: .init(title: "Example", url: "https://example.com", index: 1), count: 6)
    @State private var showingPopover = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Label(searchString == nil ? "Searching" : "Search Results", systemImage: "network")
                .foregroundColor(.cyan)
                .font(.title3.bold())
                .shimmerWithoutRedact(when: searchString == nil)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(results) { result in
                        Link(destination: URL(string: result.url) ?? URL(string: "https://github.com")!) {
                            pillContent(favicon: result.faviconURL, text: result.displayDomain)
                        }
                        .disabled(searchString == nil)
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
                    .disabled(searchString == nil)
                    .popover(isPresented: $showingPopover) {
                        SearchResultsPopover(results: results)
                            .presentationDetents(horizontalSizeClass == .compact ? [.medium] : [.large])
                            .presentationDragIndicator(.hidden)
                    }
                }
            }
        }
        .task(id: searchString) {
            guard searchString != nil else { return }
            await parseResults()
        }
    }
    
    private func pillContent(favicon: String?, text: String) -> some View {
        HStack(spacing: 6) {
            if let favicon = favicon {
                AsyncImage(url: URL(string: favicon)) { image in
                    image
                        .resizable()
                        .frame(width: 15, height: 15)
                } placeholder: {
                    Image(systemName: "globe")
                        .frame(width: 15, height: 15)
                        .foregroundColor(.secondary)
                }
            } else {
                Image(systemName: "network")
                    .frame(width: 15, height: 15)
                    .foregroundColor(.secondary)
            }
            
            Text(text)
                .font(.subheadline)
        }
        .shimmer(when: searchString == nil)
        .padding(.horizontal, padding)
        .padding(.vertical, padding - 2)
        .background(.quinary.opacity(0.8))
        .cornerRadius(12)
        #if os(macOS)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        }
        #endif
    }
    
    var padding: CGFloat {
        #if os(macOS)
        return 6
        #else
        return 7
        #endif
    }
    
    private func parseResults() async {
        let entries = searchString?.components(separatedBy: "\n\n") ?? []
        var parsedResults: [SearchResult] = []
        
        for entry in entries {
            let lines = entry.components(separatedBy: "\n")
            if lines.count >= 3 {
                let titleLine = lines[0].trimmingCharacters(in: .whitespaces)
                let urlLine = lines[1].trimmingCharacters(in: .whitespaces)
                
                if let index = titleLine.firstMatch(of: /\[(\d+)\]/)?.1,
                   let indexNum = Int(index) {
                    let title = titleLine.replacingOccurrences(of: "\\[\\d+\\]\\s*", with: "", options: .regularExpression)
                                       .trimmingCharacters(in: .whitespaces)
                    let url = urlLine.replacingOccurrences(of: "URL: ", with: "")
                                    .trimmingCharacters(in: .whitespaces)
                    
                    parsedResults.append(SearchResult(title: title, url: url, index: indexNum))
                }
            }
        }
        
//        withAnimation {
            self.results = parsedResults
//        }
    }
}

#Preview {
    ToolSearchView(searchString: .mockGoogleSearch)
    .frame(width: 400, height: 400)

}
