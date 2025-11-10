//
//  ExpandableText.swift
//  LynkChat
//
//  Created by Zabir Raihan on 10/11/2025.
//

import SwiftUI

struct ExpandableText: View {
    let text: String
    let maxCharacters: Int
    
    @State private var isExpanded = false
    private let needsExpansion: Bool
    
    @AppStorage("fontSize") var fontSize: Double = 13
    
    init(text: String, maxCharacters: Int = 400) {
        self.text = text
        self.maxCharacters = maxCharacters
        self.needsExpansion = text.count > maxCharacters
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 3) {
            Text(displayedText)
                .textSelection(.enabled)
                .font(.system(size: fontSize))
                .lineSpacing(2)
            
            if needsExpansion {
                Button {
                    isExpanded.toggle()
                } label: {
                    Text(isExpanded ? "Show Less" : "Show More")
                }
                .buttonBorderShape(.capsule)
            }
        }
    }
    
    private var displayedText: String {
        guard needsExpansion && !isExpanded else {
            return text
        }
        return String(text.prefix(maxCharacters))
    }
}
