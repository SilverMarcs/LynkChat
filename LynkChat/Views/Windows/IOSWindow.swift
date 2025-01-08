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
                            .onSubmit(of: .search) {
                                if PasswordHelper.verifyPassword(chatVM.searchText) {
                                    config.showDebugMenu = true
                                }
                            }
                    case .images:
                        ImageList(selection: $selection)
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
            .fullScreenCover(isPresented: .constant(!config.hasCompletedOnboarding)) {
                OnboardingView()
            }
        }
    }
}
