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
    var prompt: String = ""
    // Images user attaches to be used for editing on next send
    var inputImages: [Data] = []

    @Relationship(deleteRule: .cascade, inverse: \Generation.session)
    private var unsortedImageGenerations = [Generation]()

    var imageGenerations: [Generation] {
        get {
            unsortedImageGenerations.sorted { $0.date > $1.date }
        }
        set {
            unsortedImageGenerations = newValue
        }
    }
    
    @Relationship(deleteRule: .cascade)
    var config: ImageConfig = ImageConfig()

    init() { }
    
    func send(_ customPrompt: String? = nil) async {
        let promptToUse = customPrompt ?? prompt
        
        guard !promptToUse.isEmpty else { return }
        
        let generation = Generation(config: config, session: self)
        generation.isProcessing = true
        generation.config.prompt = promptToUse
        imageGenerations.append(generation)

        await Scroller.scrollToBottom(delay: 0.2)
        await generation.send()
        inputImages.removeAll()
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
}
