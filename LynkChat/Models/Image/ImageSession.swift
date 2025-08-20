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
    @Attribute(.ephemeral)
    var prompt: String = ""

    @Relationship(deleteRule: .cascade, inverse: \Generation.session)
    var imageGenerations = [Generation]()
    
    @Relationship(deleteRule: .cascade)
    var config: ImageConfig = ImageConfig()

    init() { }
    
    func send(_ customPrompt: String? = nil) async {
        let promptToUse = customPrompt ?? prompt
        
        guard !promptToUse.isEmpty else { return }
        
        let generation = Generation(config: config, session: self)
        generation.config.prompt = promptToUse
        
        imageGenerations.append(generation)
        
        await Scroller.scrollToBottom(delay: 0.2)
        
        await generation.send()
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

