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
            TabView(selection: $settingsVM.listState) {
                // Chats Tab
                NavigationSplitView {
                    ChatList(status: chatVM.statusFilter, searchText: chatVM.searchText)
                        .searchable(text: $chatVM.searchText)
                        .onSubmit(of: .search) {
                            if PasswordHelper.verifyPassword(chatVM.searchText) {
                                config.showDebugMenu = true
                            }
                        }
                        .toolbar {
                            toolbar
                        }
                } detail: {
                    if let chat = chatVM.activeChat {
                        ChatDetail(chat: chat)
                            .id(chat.id)
                    } else {
                        Text("^[\(chatVM.selections.count) Chat](inflect: true) Selected")
                    }
                }
                .tabItem {
                    Label("Chats", systemImage: "message")
                }
                .tag(ListState.chats)
                
                // Images Tab
                NavigationSplitView {
                    ImageList(selection: $selection)
                        .toolbar {
                            toolbar
                        }
                } detail: {
                    if let imageSession = selection {
                        ImageDetail(session: imageSession)
                    } else {
                        Text("Select or create an image session")
                    }
                }
                .tabItem {
                    Label("Images", systemImage: "photo")
                }
                .tag(ListState.images)
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .fullScreenCover(isPresented: .constant(!config.hasCompletedOnboarding)) {
                OnboardingView()
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        @Bindable var settingsVM = settingsVM
        
        ToolbarItem(placement: .topBarLeading) {
            Button(action: { settingsVM.showSettings.toggle() }) {
                Label("Settings", systemImage: "gear")
            }
            .sheet(isPresented: $settingsVM.showSettings) {
                SettingsView()
            }
        }
    }
}
