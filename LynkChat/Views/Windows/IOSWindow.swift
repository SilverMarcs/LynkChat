//
//  IOSWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/09/2024.
//

import SwiftUI
import SwiftData

struct IOSWindow: Scene {
    @ObservedObject var config = AppConfig.shared
    
    @State var selection: ImageSession?
    @State var searchText: String = ""
    
    @Bindable var chatVM = ChatVM.shared
    
    var body: some Scene {

        WindowGroup("Chats", id: "chats") {
            TabView {
                // Chats Tab
                Tab("Chats", systemImage: "message") {
                    NavigationStack(path: $chatVM.chatPath) {
                        ChatList(status: chatVM.statusFilter, searchText: chatVM.searchText)
                            .searchable(text: $searchText)
                            .onSubmit(of: .search) {
                                if PasswordHelper.verifyPassword(searchText) {
                                    config.showDebugMenu = true
                                }
                            }
                    }
                    
//                    NavigationSplitView {
//                        ChatList(status: chatVM.statusFilter, searchText: chatVM.searchText)
//                   
//                    } detail: {
//                        if let chat = chatVM.activeChat {
//                            ChatDetail(chat: chat)
//                                .id(chat.id)
//                        } else {
//                            Text("^[\(chatVM.selections.count) Chat](inflect: true) Selected")
//                        }
//                    }
                }
                
                // Images Tab
                Tab("Images", systemImage: "photo.on.rectangle.angled") {
//                    NavigationStack {
                        ImageList(selection: $selection)
//                    }
//                    NavigationSplitView {
//                        ImageList(selection: $selection)
//                    } detail: {
//                        if let imageSession = selection {
//                            ImageDetail(session: imageSession)
//                        } else {
//                            Text("Select or create an image session")
//                        }
//                    }
                }
                
                // Settings Tab
                Tab("Settings", systemImage: "gear") {
                    SettingsView()
                }
            }
//            .tabBarMinimizeBehavior(.onScrollDown)
            .fullScreenCover(isPresented: .constant(!config.hasCompletedOnboarding)) {
                OnboardingView()
            }
        }
    }
}
