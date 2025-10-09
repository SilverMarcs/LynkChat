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
    @Bindable var session: ImageSession
    
    var body: some View {
        HStack {
            ListRowImage(model: session.config.model)
            
//            HighlightableTextView(session.title, highlightedText: imageSearchText)
            Text(session.title)
                .lineLimit(1)
                .font(font)
                .opacity(0.9)
            
            Spacer()
            
            Text(session.config.model.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fontWidth(.compressed)
        }
        .swipeActions {
            Button(role: .destructive) {
                modelContext.delete(session)
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

#Preview {
    ImageRow(session: .mockImageSession)
}
