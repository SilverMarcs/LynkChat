//
//  IOSWindow.swift
//  LynkChat
//
//  Created by Zabir Raihan on 28/09/2024.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct IOSWindow: Scene {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("iosWindowType") private var windowTypeRawValue = WindowType.chats.rawValue
    
    @State private var selection: ImageSession?
    @State private var searchText: String = ""
    
    @Environment(ChatVM.self) var chatVM: ChatVM
    
    var body: some Scene {
        WindowGroup("Chats", id: "chats") {
            Group {
                switch selectedWindowType {
                case .chats:
                    chatRootView
                case .images:
                    imageRootView
                case .audio:
                    LiveAudioView()
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
            .onReceive(NotificationCenter.default.publisher(for: .sharedImagesReceived)) { notification in
                if let paths = notification.userInfo?["imagePaths"] as? [String] {
                    let newChat = chatVM.createNewChat(delay: true)
                    for path in paths {
                        let url = URL(fileURLWithPath: path)
                        guard let data = try? Data(contentsOf: url) else { continue }
                        let typedData = TypedData(data: data, fileType: .jpeg, fileName: url.lastPathComponent)
                        newChat.inputManager.dataFiles.append(typedData)
                        // Clean up the shared file
                        try? FileManager.default.removeItem(at: url)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var chatRootView: some View {
        @Bindable var chatVM = chatVM

        NavigationStack(path: $chatVM.chatPath) {
            ChatList(status: chatVM.statusFilter, searchText: searchText)
                .searchable(text: Binding(
                    get: { searchText },
                    set: { newValue in
                        withAnimation(.smooth) {
                            searchText = newValue
                        }
                    }
                ))
                .searchable(text: $searchText)
        }
        .environment(\.windowType, .chats)
        .environment(\.setWindowType, setWindowType)
    }

    @ViewBuilder
    private var imageRootView: some View {
        ImageList(selection: $selection)
            .environment(\.windowType, .images)
            .environment(\.setWindowType, setWindowType)
    }

    private var selectedWindowType: WindowType {
        WindowType(rawValue: windowTypeRawValue) ?? .chats
    }

    private func setWindowType(_ newValue: WindowType) {
        windowTypeRawValue = newValue.rawValue
    }
    
    @ViewBuilder
    var oldView: some View {
        @Bindable var chatVM = chatVM
        
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
        .onReceive(NotificationCenter.default.publisher(for: .sharedImagesReceived)) { notification in
            if let paths = notification.userInfo?["imagePaths"] as? [String] {
                let newChat = chatVM.createNewChat(delay: true)
                for path in paths {
                    let url = URL(fileURLWithPath: path)
                    guard let data = try? Data(contentsOf: url) else { continue }
                    let typedData = TypedData(data: data, fileType: .jpeg, fileName: url.lastPathComponent)
                    newChat.inputManager.dataFiles.append(typedData)
                    try? FileManager.default.removeItem(at: url)
                }
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
