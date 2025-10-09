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
    
    @MainActor
    func send() async {
        state = .generating

        generatingTask = Task { @MainActor in
            do {
                let dataObjects: [Data]
                
                // Choose API based on mode
                if config.mode == .generation {
                    // For generation mode, just send the current prompt
                    dataObjects = try await APIService.generateImageWithWavespeed(
                        prompt: config.prompt,
                        numImages: config.numImages
                    )
                } else {
                    // For editing mode, send all images and prompts from history
                    guard let session = session else {
                        throw RuntimeError("No session found for editing")
                    }
                    
                    let historyImages = session.getAllHistoryImages()
                    let historyPrompts = session.getAllHistoryPrompts()
                    
                    dataObjects = try await APIService.editImageWithWavespeed(
                        prompt: config.prompt,
                        images: historyImages,
                        contextPrompts: historyPrompts,
                        numImages: config.numImages
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
