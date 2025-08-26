//
//  ToolRagView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/08/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ToolRagView: View {
    let result: String?
    
    private let ragResponse: RAGResponse?
    
    init(result: String?) {
        self.result = result
        
        // Parse once during initialization
        if let result = result,
           let data = result.data(using: .utf8) {
            self.ragResponse = try? JSONDecoder().decode(RAGResponse.self, from: data)
        } else {
            self.ragResponse = nil
        }
    }
    
    var body: some View {
        if let ragResponse = ragResponse {
            FlowLayout {
                ForEach(ragResponse.content, id: \.similarity) { content in
                    RAGContentView(content: content)
                }
            }
        } else {
            FlowLayout {
                ForEach(0..<5, id: \.self) { _ in
                    RAGContentView(content: .init(text: "com.example.com", similarity: 0.44, filename: "longfileName", fileExtension: "pdf"))
                        .shimmer(when: true)
                }
            }
        }
    }
}

struct RAGContentView: View {
    let content: RAGContent
    let image: PlatformImage
    @State var showPopover: Bool = false
    
    init(content: RAGContent) {
        self.content = content
        #if os(macOS)
        self.image = NSWorkspace.shared.icon(for: UTType(filenameExtension: content.fileExtension) ?? .avi)
        #else
        self.image = PlatformImage(systemName: "doc.on.doc.fill")!
        #endif
    }
    
    var body: some View {
        Button {
            showPopover.toggle()
        } label: {
            HStack {
                Image(platformImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 27, height: 27)
                
                VStack(alignment: .leading) {
                    Text(content.filename.prefix(15))
                        .lineLimit(1)
                        .font(.headline)

                    Text("\(content.similarity)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .popover(isPresented: $showPopover) {
            ScrollView {
                Text(LocalizedStringKey(content.text))
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium])
            .contentMargins(20, for: .scrollContent)
            .frame(maxWidth: 500)
        }
    }
}

#Preview {
    ToolRagView(result: """
    {
        "count": "3",
        "fileName": "document.pdf",
        "content": [
            {
                "text": "This is some sample text from the document.",
                "similarity": 0.8542
            },
            {
                "text": "Another piece of relevant content.",
                "similarity": 0.7321
            }
        ]
    }
    """)
}
