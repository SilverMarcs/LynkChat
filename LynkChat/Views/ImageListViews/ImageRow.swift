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
            
            HighlightableTextView(session.title, highlightedText: imageSearchText)
                .lineLimit(1)
                .font(.headline)
                .fontWeight(.regular)
                .opacity(0.9)
            
            Spacer()
            
            Text(session.config.model.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fontWidth(.compressed)
        }
        .padding(3)
        .swipeActions {
            Button(role: .destructive) {
                modelContext.delete(session)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    ImageRow(session: .mockImageSession)
}
