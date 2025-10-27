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
    
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
//        try container.mainContext.delete(model: ImageSession.self)
//        try container.mainContext.delete(model: Chat.self)
        let modelContext = container.mainContext
        
        return container
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
