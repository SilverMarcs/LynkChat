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
    @Environment(\.setWindowType) private var setWindowType

    @Binding var selection: ImageSession?
    
    @Query(sort: \ImageSession.date, order: .reverse, animation: .default)
    var sessions: [ImageSession]
    
    @State var searchText: String = ""
    @State var imagePath: NavigationPath = NavigationPath()
    @State private var showSettings = false

    @Namespace private var transition
    
    var body: some View {
        list
            .searchable(text: $searchText, placement: searchPlacement)
    }
    
    @ViewBuilder
    private var list: some View {
        #if os(macOS)
        List(selection: $selection) {
            ChatListCards(chatCount: "↗", imageSessionsCount: String(sessions.count))
            
            ForEach(sessions) { session in
                ImageRow(session: session)
                    .environment(\.imageSearchText, searchText)
                    .tag(session)
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
            if selection == nil, let first = sessions.first, !(horizontalSizeClass == .compact) {
                selection = first
            }
        }
        #else
        NavigationStack(path: $imagePath) {
            List {
                ForEach(sessions) { session in
                    NavigationLink(value: session) {
                        ImageRow(session: session)
                    }
                    .environment(\.imageSearchText, searchText)
                    .tag(session)
                }
                .onDelete(perform: deleteItems)
            }
            .contentMargins(.top, 10)
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationTitle("Images")
            .toolbar {
                toolbar
            }
            .navigationDestination(for: ImageSession.self) { session in
                ImageDetail(session: session)
            }
        }
        #endif
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button {
                    setWindowType(.chats)
                } label: {
                    Label("Chats", systemImage: "message")
                }
            } label: {
                Label("Settings", systemImage: "gear")
            } primaryAction: {
                showSettings = true
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .navigationTransition(.zoom(sourceID: "image-settings", in: transition))
            }
        }
        .matchedTransitionSource(id: "image-settings", in: transition)

        DefaultToolbarItem(kind: .search, placement: .bottomBar)
        ToolbarSpacer(placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                createImageSession()
            } label: {
                Label("New Image", systemImage: "square.and.pencil")
            }
        }
        #else
        ToolbarSpacer(placement: .primaryAction)
        
        ToolbarItem(placement: .primaryAction) {
            Button {
                createImageSession()
            } label: {
                Label("Add Item", systemImage: "square.and.pencil")
            }
            .keyboardShortcut("n")
        }
        #endif
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
            let session = sessions[index]
            if selection == session {
                selection = nil
            }
                
            modelContext.delete(session)
        }
    }

    private func createImageSession() {
        let imageSession = ImageSession()
        modelContext.insert(imageSession)
        selection = imageSession
        imagePath.append(imageSession)
    }
}


#Preview {
    ImageList(selection: .constant(nil))
}
