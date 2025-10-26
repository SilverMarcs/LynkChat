//
//  Generation.swift
//  LynkChat
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Generation

@Model
class Generation {
    var id: UUID = UUID()
    var date: Date = Date()
    var title: String = "Image Session"
    
    var prompt: String = ""
    var generationMode: GenerationMode = GenerationMode.create
    
    var inputImageData: Data?
    
    var imageTasks: [ImageTask] = []
    
    init() {}
    
    // MARK: - Business Logic
    
    var hasInputImage: Bool {
        inputImageData != nil
    }
    
    func queueTask() {
        let config: ImageConfigDefaults = ImageConfigDefaults()
        
        let task = ImageTask(
            prompt: prompt,
            mode: generationMode,
            config: config,
            inputImageData: inputImageData
        )
        
        imageTasks.append(task)
    }
}

// MARK: - Errors

enum GenerationError: LocalizedError {
    case noImageGenerated
    case noInputImage
    case noEditedImageReturned
    
    var errorDescription: String? {
        switch self {
        case .noImageGenerated:
            return "No image generated"
        case .noInputImage:
            return "No input image available"
        case .noEditedImageReturned:
            return "No edited image returned"
        }
    }
}
