//
//  IOSWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/09/2024.
//

import SwiftUI
import SwiftData

struct IOSWindow: Scene {
    @Environment(SettingsVM.self) private var settingsVM
    @Environment(ChatVM.self) private var chatVM
    
    @ObservedObject var config = AppConfig.shared
    
    @State var selection: ImageSession?
    
    var body: some Scene {
        @Bindable var chatVM = chatVM
        @Bindable var settingsVM = settingsVM
        
        WindowGroup("Chats", id: "chats") {
            NavigationSplitView {
                Group {
                    switch settingsVM.listState {
                    case .chats:
                        ChatList(status: chatVM.statusFilter, searchText: chatVM.searchText)
                            .searchable(text: $chatVM.searchText)
                    case .images:
                        ImageListIOS(selection: $selection)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button(action: { settingsVM.showSettings.toggle() }) {
                                Label("Settings", systemImage: "gear")
                            }
                        } label: {
                            Label("More", systemImage: "ellipsis.circle")
                                .labelStyle(.titleOnly)
                        }
                        .sheet(isPresented: $settingsVM.showSettings) {
                            SettingsView()
                        }
                    }
                }
            } detail: {
                switch settingsVM.listState {
                case .chats:
                    if let chat = chatVM.activeChat {
                        ChatDetail(chat: chat)
                            .id(chat.id)
                    } else {
                        Text("^[\(chatVM.selections.count) Chat](inflect: true) Selected")
                    }
                case .images:
                    if let imageSession = selection {
                        ImageDetail(session: imageSession)
                    } else {
                        Text("Select or create an image session")
                    }
                }
            }
            .sheet(isPresented: .constant(!config.hasCompletedOnboarding)) {
                OnboardingView()
            }
        }
    }
}

struct ImageListIOS: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.modelContext) var modelContext

    @Binding var selection: ImageSession?
    
    @Query(sort: \ImageSession.date, order: .reverse, animation: .default)
    var sessions: [ImageSession]
    
    @State var searchText: String = ""
    
    var body: some View {
        ScrollViewReader { proxy in
            List(selection: $selection) {
                ChatListCards(source: .images, chatCount: "↗", imageSessionsCount: String(sessions.count))
                
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
        ToolbarItem { Spacer() }
        
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
