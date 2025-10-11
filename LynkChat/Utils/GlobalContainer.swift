//
//  GlobalContainer.swift
//  LynkChat
//
//  Created by Zabir Raihan on 01/01/2025.
//

import SwiftData
import Foundation

let globalContainer: ModelContainer = {
    print((URL.applicationSupportDirectory.path(percentEncoded: false)))
    let schema = Schema([
        Chat.self,
        Message.self,
        MessageGroup.self,
        Generation.self,
    ])
    
    let modelConfiguration = ModelConfiguration("LynkChatDB", schema: schema, isStoredInMemoryOnly: false)

    do {
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
//        try container.mainContext.delete(model: ImageSession.self)
//        try container.mainContext.delete(model: Chat.self)
        let modelContext = container.mainContext
        
        // fetch chats with temporary status
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
        
        let chat = Chat()
        chat.config.models = [.gemini_flash]
        chat.title = "Welcome to LynkChat"
        let group = MessageGroup(message: Message.assistant(model: .gemini_flash, content: String.onboarding))
        chat.rootMessage = group
        modelContext.insert(chat)
        
        // Image session,
        modelContext.insert(ImageSession())
        
        AppConfig.shared.finishedInitialSetup = true
        
        return container
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
