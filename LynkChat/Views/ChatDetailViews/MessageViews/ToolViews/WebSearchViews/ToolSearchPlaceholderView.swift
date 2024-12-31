//
//  ToolSearchPlaceholderView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolSearchPlaceholderView: View {
    var body: some View {
        #if os(macOS)
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
                        
                        HStack(spacing: 5) {
                            Image(systemName: "globe")
                                .frame(width: 12, height: 12)
                                .foregroundStyle(Color.getRandomColor())
                            
                            Text("wwwbbccom")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 4)
                    .frame(width: 155, height: 50, alignment: .leading)
                    .shimmer(when: true)
                }
                .groupBoxStyle(PlatformGroupBoxStyle())
            }
            
            GroupBox {
                VStack {
                    ForEach(1...3, id: \.self) { number in
                        Image(systemName: "globe")
                            .frame(width: 10, height: 10)
                            .foregroundStyle(Color.getRandomColor())
                    }
                }
                .padding(.horizontal, 5)
                .frame(height: 50)
                .shimmer(when: true)
            }
            .groupBoxStyle(PlatformGroupBoxStyle())
        }
        #else
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(1...4, id: \.self) { number in
                    HStack(spacing: 6) {
                        Image(systemName: "globe")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.getRandomColor())
                        
                        Text("wwwbbccom")
                            .font(.subheadline)
                    }
                    .shimmer(when: true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                }
            }
        }
        #endif
    }
    
    private var count: Int {
        #if os(macOS) || os(visionOS)
        return 4
        #else
        return 2
        #endif
    }
}

#Preview {
    ToolSearchPlaceholderView()
}
