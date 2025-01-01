//
//  LynkChatApp.swift
//  LynkChat
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct LynkChatApp: App {
    @State private var chatVM: ChatVM = ChatVM()
    @State private var settingsVM: SettingsVM = SettingsVM()
    
    #if !os(macOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        Group {
            #if os(macOS)
            WindowScenesCollection()
            #else
            IOSWindow()
            #endif
        }
        .commands { MenuCommands() }
        .environment(chatVM)
        .environment(settingsVM)
        .modelContainer(globalContainer)
    }
    
    init() {
        #if DEBUG
        try? Tips.resetDatastore()
        #endif        
        try? Tips.configure()

        #if os(macOS)
        AppConfig.shared.hideDock = false

        QuickPanelWindow(
            chatVM: chatVM,
            modelContext: globalContainer.mainContext
        )

        #else
        // TODO: find a way to avoid having chatVM in app delegate
        AppDelegate.shared.chatVM = _chatVM.wrappedValue
        #endif
    }
}

@MainActor
let globalContainer: ModelContainer = {
    AppLogger.info(URL.applicationSupportDirectory.path(percentEncoded: false))
    let schema = Schema([
        Chat.self,
        Message.self,
        MessageGroup.self,
        Generation.self,
    ])
    
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    // TODO: if error then delete all existign data in all tables and reinit
    do {
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let modelContext = container.mainContext
        
        // fetch chats with temporary status
        // TODO: perhaps do this when changing selection
        var fetchTempChats = FetchDescriptor<Chat>()
        let tempId = ChatStatus.temporary.id
        fetchTempChats.predicate = #Predicate { $0.statusId == tempId }
        if let tempChats = try? modelContext.fetch(fetchTempChats) {
            for chat in tempChats {
                modelContext.delete(chat)
            }
        }

        if AppConfig.shared.finishedInitialSetup {
            return container // Return the container if setup is already done
        }

        // Archived chat
        let archivedChat = Chat()
        archivedChat.status = .archived
        archivedChat.statusId = ChatStatus.archived.id
        archivedChat.title = "Archived Chat"
        modelContext.insert(archivedChat)
        
        // Demo favourite chat with some messages
        let favouriteChat = Chat()
        let group = MessageGroup(message: Message.user(content: "How do i sort in python?"))
        let secondGroup = MessageGroup(message: Message.assistant(model: .gpt4omini, content: String.codeBlock))
        favouriteChat.rootMessage = group
        group.activeMessage.next = secondGroup
        favouriteChat.status = .starred
        favouriteChat.statusId = ChatStatus.starred.id
        favouriteChat.title = "Favourite Chat"
        modelContext.insert(favouriteChat)
        
        // Image session,
        modelContext.insert(ImageSession())
        
        AppConfig.shared.finishedInitialSetup = true
        
        return container
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
