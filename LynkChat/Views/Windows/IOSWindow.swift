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
    @Bindable var settings = AppSettings.shared
    
    @State var selection: ImageSession?
    @State var searchText: String = ""
    
    @Bindable var chatVM = ChatVM.shared
    
    var body: some Scene {
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
            .fullScreenCover(isPresented: .constant(!config.hasCompletedOnboarding)) {
                OnboardingView()
            }
            .fullScreenCover(isPresented: $settings.showCamera) {
                CameraView()
                    .ignoresSafeArea()
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
