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
    
    var inputImage: Data?
    
    var imageTasks: [ImageTask] = []
    
    var imageConfig: ImageConfig = ImageConfig()
    
    init() {}
    
    // MARK: - Business Logic
    
    var hasInputImage: Bool {
        inputImage != nil
    }
    
    func queueTask() {
        let task = ImageTask(
            prompt: prompt,
            mode: generationMode,
            config: imageConfig,
            inputImage: inputImage,
            onCompletion: { [weak self] task in
                guard let self else { return }
                // Remove failed tasks from the list
                if task.error != nil {
                    if let idx = self.imageTasks.firstIndex(where: { $0.id == task.id }) {
                        self.imageTasks.remove(at: idx)
                    }
                }
            }
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
