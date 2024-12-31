//
//  DatabaseService.swift
//  LynkChat
//
//  Created by Zabir Raihan on 8/31/24.
//

import SwiftUI
import Foundation
import SwiftData
import Observation

// TODO: make modelactor 

@MainActor
final class DatabaseService: NSObject {
    static let shared = DatabaseService()

    let container: ModelContainer = {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
        let schema = Schema([
            Chat.self,
            Message.self,
            MessageGroup.self,
            Generation.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

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
//            let group = MessageGroup(message: .init(role: .user, content: "How do i sort in python?", model: .gpt4omini))
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
    
    var modelContext: ModelContext {
        container.mainContext
    }
}
