//
//  ToolSearchPlaceholderView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolSearchPlaceholderView: View {
    var body: some View {
        HStack(spacing: 8) {
            // First 4 results
            ForEach(1...4, id: \.self) { number in
                GroupBox {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("This is a very very long title that is going to be cut off")
                            .font(.subheadline).fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .lineSpacing(0.1)
                            .foregroundStyle(.link)
                            .redacted(reason: .placeholder)
                        
                        HStack(spacing: 5) {
                            Image(systemName: "globe")
                                .frame(width: 12, height: 12)
                                .foregroundStyle(Color.getRandomColor())
                                .redacted(reason: .placeholder)
                            
                            Text("wwwbbccom")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .redacted(reason: .placeholder)
                        }
                    }
                    .padding(.horizontal, 4)
                    .frame(width: 155, height: 50, alignment: .leading)
                }
                .groupBoxStyle(PlatformGroupBoxStyle())
            }
            
            GroupBox {
                VStack {
                    ForEach(1...3, id: \.self) { number in
                        Image(systemName: "globe")
                            .frame(width: 10, height: 10)
                            .foregroundStyle(Color.getRandomColor())
                            .redacted(reason: .placeholder)
                    }
                }
                .padding(.horizontal, 5)
                .frame(height: 50)
            }
            .groupBoxStyle(PlatformGroupBoxStyle())
        }
    }
}

#Preview {
    ToolSearchPlaceholderView()
}
