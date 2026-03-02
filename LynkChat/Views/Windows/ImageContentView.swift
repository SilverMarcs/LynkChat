//
//  ImageContentView.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/09/2024.
//

import SwiftUI

struct ImageContentView: View {
    @State var showingInspector: Bool = true
    @State var selection: ImageSession?
    
    var body: some View {
        NavigationSplitView {
            ImageList(selection: $selection)
                #if os(macOS)
                .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 400)
                #endif
        } detail: {
            if let imageSession = selection {
                ImageDetail(session: imageSession)
                    .id(imageSession.id)
            } else {
                ScrollView {
                    Text("Select or create an image session")
                        .font(.title)
                }
            }
        }
        .inspector(isPresented: $showingInspector) {
            if let imageSession = selection {
                ImageInspector(session: imageSession, showingInspector: $showingInspector)
                    .id(imageSession.id)
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
