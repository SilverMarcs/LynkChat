//
//  ToolSearchPlaceholderView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 30/12/2024.
//

import SwiftUI

struct ToolSearchPlaceholderView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(1...8, id: \.self) { number in
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
                    .background(.quinary)
                    .cornerRadius(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.quaternary, lineWidth: 1)
                    }
                }
            }
        }
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
