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
            ImageConfig.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let modelContext = container.mainContext
            
            var fetchQuickChats = FetchDescriptor<Chat>()
            let quickId = ChatStatus.quick.id
            fetchQuickChats.predicate = #Predicate { $0.statusId == quickId }
            fetchQuickChats.fetchLimit = 1
            if let quickChat = try? modelContext.fetch(fetchQuickChats).first {
                quickChat.deleteAllMessages()
                quickChat.config.model = ModelConfig.shared.quickModel
            }
            
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
            
            // Quick chat
            let chat = Chat()
            chat.config.systemPrompt = AppConfig.shared.quickSystemPrompt // TOOD: see
            chat.status = .quick
            chat.statusId = ChatStatus.quick.id
            chat.title = "(↯) Quick Chat"
            modelContext.insert(chat)
            
            // Demo chat with no messages
            let normalChat = Chat()
            normalChat.totalTokens = 181
            modelContext.insert(normalChat)

            // Archived chat
            let archivedChat = Chat()
            archivedChat.status = .archived
            archivedChat.statusId = ChatStatus.archived.id
            archivedChat.title = "Archived Chat"
            modelContext.insert(archivedChat)
            
            // Demo favourite chat with some messages
            let favouriteChat = Chat()
            favouriteChat.status = .starred
            favouriteChat.statusId = ChatStatus.starred.id
            // TODO: add this
//            favouriteChat.addMessage(.mockUserMessage)
//            favouriteChat.messages.append(.mockAssistantGroup)
            favouriteChat.title = "Favourite Chat"
            modelContext.insert(favouriteChat)
            
            // Image session
            let imageModel = AIModel(code: "dall-e-3", name: "DALL-E-3")
            let imageModel2 = AIModel(code: "dall-e-2", name: "DALL-E-2")
            let imageProvder = ImageProvider(name: "OpenAI", baseUrl: "api.openai.com/v1", model: imageModel)
            imageProvder.models.append(imageModel2)
            let imageChatConfig = ImageConfig(provider: imageProvder)
            let imageSession = ImageSession(config: imageChatConfig)
            modelContext.insert(imageSession)
            
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
