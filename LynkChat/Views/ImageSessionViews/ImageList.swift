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

    @Binding var selection: Generation?
    
    @Query(sort: \Generation.date, order: .reverse, animation: .default)
    var generations: [Generation]
    
    @State var searchText: String = ""
    @State var imagePath: NavigationPath = NavigationPath()
    
    var body: some View {
        list
            .searchable(text: $searchText, placement: searchPlacement)
    }
    
    @ViewBuilder
    private var list: some View {
        #if os(macOS)
        List(selection: $selection) {
            ChatListCards(chatCount: "↗", imageSessionsCount: String(generations.count))
            
            ForEach(generations) { generation in
                ImageRow(generation: generation)
                    .environment(\.imageSearchText, searchText)
                    .tag(generation)
                    .listRowSeparator(.visible)
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("Images")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            toolbar
        }
        .task {
            if selection == nil, let first = generations.first, !(horizontalSizeClass == .compact) {
                selection = first
            }
        }
        #else
        NavigationStack(path: $imagePath) {
            List {
                ForEach(generations) { generation in
                    NavigationLink(value: generation) {
                        ImageRow(generation: generation)
                    }
                    .environment(\.imageSearchText, searchText)
                }
                .onDelete(perform: deleteItems)
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationTitle("Images")
            .toolbar {
                toolbar
            }
            .navigationDestination(for: Generation.self) { generation in
                GenerationView(generation: generation)
            }
        }
        #endif
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarSpacer(placement: .primaryAction)
        
        ToolbarItem(placement: .primaryAction) {
            Button {
                let generation = Generation()
                modelContext.insert(generation)
                selection = generation
                imagePath.append(generation)
            } label: {
                Label("Add Item", systemImage: "square.and.pencil")
            }
            .keyboardShortcut("n")
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
            let generation = generations[index]
            if selection == generation {
                selection = nil
            }
                
            modelContext.delete(generation)
        }
    }
}


#Preview {
    ImageList(selection: .constant(nil))
}
