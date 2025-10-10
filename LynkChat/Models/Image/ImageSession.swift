//
//  ImageSession.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class ImageSession {
    var id: UUID = UUID()
    var date: Date = Date()
    var title: String = "Image Session"
    
    @Transient
    var inputManager: ImageInputManager = ImageInputManager()

    @Relationship(deleteRule: .cascade, inverse: \Generation.session)
    var imageGenerations = [Generation]()
    
    @Relationship(deleteRule: .cascade)
    var config: ImageConfig = ImageConfig()

    init() { }
    
    func send(_ customPrompt: String? = nil) async {
        let inputManagerPrompt = await inputManager.prompt
        let promptToUse = customPrompt ?? inputManagerPrompt
        
        guard !promptToUse.isEmpty else { return }
        
        let generation = Generation(config: config, session: self)
        generation.config.prompt = promptToUse
        generation.inputImages = await inputManager.inputImages
        
        imageGenerations.append(generation)
        
        await Scroller.scrollToBottom(delay: 0.2)
        
        await generation.send()
        await inputManager.clearImages()
    }
    
    func deleteGeneration(_ generation: Generation) {
        imageGenerations.removeAll(where: { $0 == generation })
        modelContext?.delete(generation)
    }
    
    func deleteAllGenerations() {
        while let generation = imageGenerations.popLast() {
            modelContext?.delete(generation)
        }
    }
    
    // Get all images from history for editing mode
    func getAllHistoryImages() -> [Data] {
        var allImages: [Data] = []
        
        // Add uploaded images
        allImages.append(contentsOf: inputManager.inputImages)
        
        // Add generated images from all generations
        for generation in imageGenerations.sorted(by: { $0.date < $1.date }) {
            allImages.append(contentsOf: generation.images)
        }
        
        return allImages
    }
    
    // Get all prompts from history for editing mode
    func getAllHistoryPrompts() -> [String] {
        return imageGenerations
            .sorted(by: { $0.date < $1.date })
            .map { $0.config.prompt }
    }
} 
