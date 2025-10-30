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
    var inputImages: [Data] = []
    
    @Relationship(deleteRule: .cascade)
    var config: ImageConfig = ImageConfig()

    @Relationship(deleteRule: .cascade, inverse: \Generation.session)
    var imageGenerations: [Generation] = [Generation]()

    init() { }
    
    func send() async {
        guard !config.prompt.isEmpty else { return }
        
        let generation = Generation(config: config, session: self)
        imageGenerations.append(generation)

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
