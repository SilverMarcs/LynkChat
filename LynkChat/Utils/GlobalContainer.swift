//
//  GlobalContainer.swift
//  LynkChat
//
//  Created by Zabir Raihan on 01/01/2025.
//

import SwiftData
import Foundation

@MainActor
let globalContainer: ModelContainer = {
//    AppLogger.info(URL.applicationSupportDirectory.path(percentEncoded: false))
    print((URL.applicationSupportDirectory.path(percentEncoded: false)))
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
        
        // Create default chats
//        for model in ChatModel.allCases {
//            let chat = Chat()
//            chat.config.model = model
//            chat.title = model.name + " Chat"
//            let group = MessageGroup(message: Message.assistant(model: model, content: "Hi I am \(model.name). How may I help you?"))
//            modelContext.insert(chat)
//        }
        // TODO create chats with info/help
        
        // Image session,
        modelContext.insert(ImageSession())
        
        AppConfig.shared.finishedInitialSetup = true
        
        return container
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
