//
//  IOSWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/09/2024.
//

import SwiftUI
import SwiftData

struct IOSWindow: Scene {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

    @Bindable var settings = AppSettings.shared
    
    @State var selection: ImageSession?
    @State var searchText: String = ""
    
    @Environment(ChatVM.self) var chatVM: ChatVM
    
    var body: some Scene {
        @Bindable var chatVM = chatVM

        WindowGroup("Chats", id: "chats") {
            TabView {
                Tab("Chats", systemImage: "message") {
                    NavigationStack(path: $chatVM.chatPath) {
                        ChatList(status: chatVM.statusFilter, searchText: searchText)
                            .searchable(text: $searchText)
                            .onAppear {
                                // Clear current chat when back at chat list
                                if chatVM.chatPath.isEmpty {
                                    chatVM.activeChat = nil
                                }
                            }
                    }
                    .onChange(of: chatVM.chatPath) {
                        // Clear current chat when path becomes empty
                        if chatVM.chatPath.isEmpty {
                            chatVM.activeChat = nil
                        }
                    }
                }
                
                Tab("Images", systemImage: "photo.on.rectangle.angled") {
                    ImageList(selection: $selection)
                }
                
                Tab("Live", systemImage: "waveform") {
                    LiveAudioView()
                }
                
                // Settings Tab
                Tab("Settings", systemImage: "gear") {
                    SettingsView()
                }
            }
            .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
                OnboardingView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .sharedContentReceived)) { notification in
                if let payload = notification.userInfo?["payload"] as? String {
                    let newChat = chatVM.createNewChat(delay: true)
                    newChat.inputManager.prompt = payload
                }
            }
//            .onAppIntentExecution(CreateChatIntent.self) { intent in
//                print("hiii")
//                let trimmedMessage = intent.target.trimmingCharacters(in: .whitespacesAndNewlines)
//                let newChat = ChatVM.shared.createNewChat(delay: true)
//                
//                Task {
//                    await newChat.sendInput(prompt: trimmedMessage)
//                }
//            }
        }
    }
}
