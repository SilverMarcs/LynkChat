//
//  GlobalContainer.swift
//  LynkChat
//
//  Created by Zabir Raihan on 01/01/2025.
//

import SwiftData
import Foundation

let globalContainer: ModelContainer = {
//    print((URL.applicationSupportDirectory.path(percentEncoded: false)))
    let schema = Schema([
        Chat.self,
        Message.self,
        MessageGroup.self,
        
        ImageSession.self,
        Generation.self,
    ])
    
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
//        try container.mainContext.delete(model: ImageSession.self)
//        try container.mainContext.delete(model: Generation.self)
        
//        try container.mainContext.delete(model: Chat.self)
//        try container.mainContext.delete(model: Message.self)
//        try container.mainContext.delete(model: MessageGroup.self)
        
        let modelContext = container.mainContext

        return container
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
