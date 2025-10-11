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

    // Any user-provided input images used for editing in this step
    @Relationship(deleteRule: .cascade)
    var inputImages: [Data] = []

    // Track whether this step is generation or editing
    var mode: GenerationMode = GenerationMode.generation
    
    @Attribute(.ephemeral)
    var state: GenerationState
    
    @Transient
    var generatingTask: Task<Void, Error>?

    init(config: ImageConfig, session: ImageSession) {
        self.config = config
        self.session = session
        self.state = .generating
    }
    
    @MainActor
    func send() async {
        state = .generating

        generatingTask = Task { @MainActor in
            do {
                let dataObjects: [Data]
                switch mode {
                case .generation:
                    dataObjects = try await APIService.generateImages(config: config)
                case .editing:
                    let history = session?.imageGenerations ?? []
                    dataObjects = try await ImageEditingService.editImages(
                        using: config.editingModel,
                        allHistory: history
                    )
                }

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
    
        Scroller.scrollToBottom(delay: 0.1)
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

enum GenerationState: Codable, Sendable {
    case generating
    case success
    case error
}

enum GenerationMode: String, Codable, Sendable {
    case generation
    case editing
}
