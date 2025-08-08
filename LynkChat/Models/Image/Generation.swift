//
//  Generation.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Generation {
    var id: UUID = UUID()
    var date: Date = Date()
    
    var session: ImageSession?
    
    var errorMessage: String = ""
    
    @Relationship(deleteRule: .nullify)
    var config: ImageConfig
    
    @Relationship(deleteRule: .cascade)
    var images: [Data] = []
    
    @Attribute(.ephemeral)
    var state: GenerationState
    
    @Transient
    var generatingTask: Task<Void, Error>?

    init(config: ImageConfig, session: ImageSession) {
        self.config = config
        self.session = session
        self.state = .generating
    }
    
    func send() async {
        state = .generating

        generatingTask = Task { @MainActor in
            do {
                let dataObjects = try await ImageGenerator.generateImages(config: config)
                
                self.images = dataObjects
                state = .success
            } catch {
                if state != .error {
                    errorMessage = "\(error.localizedDescription)"
                    state = .error
                }
            }
        }

        do {
            #if os(macOS)
            try await generatingTask?.value
            #else
            let application = UIApplication.shared
            let taskId = application.beginBackgroundTask {
                // Handle expiration of background task here
            }

            try await generatingTask?.value

            application.endBackgroundTask(taskId)
            #endif
        } catch {
            errorMessage = error.localizedDescription
            state = .error
        }
    
        await Scroller.scrollToBottom(delay: 0.2)
    }
    
    func stopGenerating() {
        generatingTask?.cancel()
        state = .error
        errorMessage = "Generation was stopped"
    }
    
    func deleteSelf() {
        session?.deleteGeneration(self)
    }
}

enum GenerationState: Codable {
    case generating
    case success
    case error
}
