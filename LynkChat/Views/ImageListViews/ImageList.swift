//
//  ImageList.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageList: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.modelContext) var modelContext

    @Binding var selection: ImageSession?
    
    @Query(sort: \ImageSession.date, order: .reverse, animation: .default)
    var sessions: [ImageSession]
    
    @State var searchText: String = ""
    
    var body: some View {
        ScrollViewReader { proxy in
            List(selection: $selection) {
                #if os(macOS)
                ChatListCards(source: .images, chatCount: "↗", imageSessionsCount: String(sessions.count))
                #endif
                
                ForEach(sessions) { session in
                    ImageRow(session: session)
                        .environment(\.imageSearchText, searchText)
                        .tag(session)
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(Color.gray.opacity(0.2))
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                toolbar
            }
            .navigationTitle("Images")
            .searchable(text: $searchText, placement: searchPlacement)
            .task {
                if selection == nil, let first = sessions.first, !(horizontalSizeClass == .compact) {
                    selection = first
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarSpacer()
        
        ToolbarItem(placement: .automatic) {
            Button {
                let imageSession = ImageSession()
                modelContext.insert(imageSession)
                selection = imageSession
            } label: {
                Label("Add Item", systemImage: "square.and.pencil")
            }
            .keyboardShortcut(.none)
        }
    }
    
    private var searchPlacement: SearchFieldPlacement {
        #if os(macOS)
        return .sidebar
        #else
        return .automatic
        #endif
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
//            if imageVM.selections.contains(sessions[index]) {
//                imageVM.selections.remove(sessions[index])
//            }
            let session = sessions[index]
            if selection == session {
                selection = nil
            }
                
            modelContext.delete(session)
        }
    }
}


#Preview {
    ImageList(selection: .constant(nil))
}
