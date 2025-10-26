//
//  ImageRow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI
import SwiftData

struct ImageRow: View {
    @Environment(\.imageSearchText) var imageSearchText
    @Environment(\.modelContext) var modelContext
    @Bindable var generation: Generation
    
    var body: some View {
        HStack {
//            ListRowImage(model: session.config.model)
            
            HighlightableTextView(generation.title, highlightedText: imageSearchText)
                .lineLimit(1)
                .font(font)
                .opacity(0.9)
            
            Spacer()
            
//            Text(session.config.model.name)
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//                .fontWidth(.compressed)
        }
        .swipeActions {
            Button(role: .destructive) {
                modelContext.delete(generation)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    var font: Font {
        #if os(macOS)
        return .headline.weight(.regular)
        #else
        return .headline.weight(.medium)
        #endif
    }
}
