//
//  ToolRagView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/08/2025.
//

import SwiftUI

struct ToolRagView: View {
    let result: String?
    
    var body: some View {
        if let result = result,
           let data = result.data(using: .utf8),
           let ragResponse = try? JSONDecoder().decode(RAGResponse.self, from: data) {
            
            FlowLayout {
                ForEach(Array(ragResponse.content.enumerated()), id: \.offset) { index, content in
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(content.filename)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(unsafe String(format: "%.2f", content.similarity * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)

                        }
                    }
                    .groupBoxStyle(PlatformGroupBox())
                    .frame(maxWidth: 300)
                }
            }
        } else {
            Text(result ?? "nil")
                .foregroundStyle(.secondary)
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
