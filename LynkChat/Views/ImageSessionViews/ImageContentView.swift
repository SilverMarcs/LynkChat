//
//  ImageContentView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/09/2024.
//

import SwiftUI

struct ImageContentView: View {
    @Environment(\.undoManager) var undoManager
    @Environment(\.modelContext) var modelContext
    
    @State var showingInspector: Bool = true
    @State var selection: Generation?
    
    var body: some View {
        NavigationSplitView {
            ImageList(selection: $selection)
                #if os(macOS)
                .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 400)
                #endif
        } detail: {
            if let generation = selection {
                GenerationView(generation: generation)
                    .id(generation.id)
            } else {
                Text("Select or create an image session")
                    .font(.title)
            }
        }
        .onAppear {
            modelContext.undoManager = undoManager
        }
        .inspector(isPresented: $showingInspector) {
            if let generation = selection {
//                ImageInspector(session: imageSession, showingInspector: $showingInspector)
                ImageConfigSheet(generation: generation)
                    .id(generation.id)
            } else {
                Image(systemName: "gear")
                    .imageScale(.large)
            }
        }
    }
}

#Preview {
    ImageContentView()
}
