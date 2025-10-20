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
    
    var session: ImageSession
    
    var errorMessage: String?
    
    @Relationship(deleteRule: .cascade)
    var config: ImageConfig
    
    var imageURLs: [URL] = []
    var videoURLs: [URL] = []

    var inputImages: [Data] = []

    // Track whether this step is generation or editing
    var mode: GenerationMode = GenerationMode.generation
    
    @Attribute(.ephemeral)
    var isGenerating: Bool = false
    
    @Transient
    var generatingTask: Task<Void, Error>?

    init(config: ImageConfig, session: ImageSession) {
         self.config = config
         self.session = session
    }
    
    @MainActor
    func send() async {
        isGenerating = true
        errorMessage = nil

        generatingTask = Task { @MainActor in
             do {
                 let urlList: [URL]
                 switch mode {
                 case .generation:
                     urlList = try await ImageGenerationService.generateImages(config: config)
                     self.imageURLs = urlList
                 case .editing:
                     urlList = try await ImageEditingService.editImages(
                         using: config.editingModel,
                         prompt: config.prompt,
                         imageURLs:  getImageListForEditing()
                     )
                     self.imageURLs = urlList
                 case .video:
                     urlList = try await VideoGenerationService.generateVideos(
                         prompt: config.prompt,
                         imageURLs: getImageListForEditing()
                     )
                     self.videoURLs = urlList
                 }

                 isGenerating = false
            } catch {
                errorMessage = error.localizedDescription
                isGenerating = false
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
            isGenerating = false
        }
        
        Scroller.scroll(to: .bottom, of: self.id, delay: 0.2)
    }

    private func getImageListForEditing() -> [String] {
        if !inputImages.isEmpty {
            // Convert Data to base64 strings
            return inputImages.map { imageData in
                "data:image/jpeg;base64," + imageData.base64EncodedString()
            }
        } else {
            // Get images from previous generation
            if let currentIndex = session.imageGenerations.firstIndex(where: { $0.id == self.id }),
               currentIndex > 0 {
                let previousGeneration = session.imageGenerations[currentIndex - 1]
                return previousGeneration.imageURLs.map { $0.absoluteString }
            } else {
                return []
            }
        }
    }
    
    func stopGenerating() {
         generatingTask?.cancel()
         isGenerating = false
         errorMessage = "Generation was stopped"
    }
    
    func deleteSelf() {
        session.deleteGeneration(self)
    }
}
