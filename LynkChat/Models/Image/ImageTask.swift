//
//  ImageTask.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/10/2025.
//

import SwiftData
import SwiftUI

@Model
final class ImageTask {
    var id: UUID = UUID()
    var prompt: String
    var mode: GenerationMode
    var imageData: Data?
    var isProcessing: Bool = true
    var error: String?
    var createdAt: Date = Date()
    
    // Non-persisted properties
    var config: ImageConfig
    @Transient var onCompletion: ((ImageTask) -> Void)?
    
    init(
        prompt: String,
        mode: GenerationMode,
        config: ImageConfig,
        inputImage: Data? = nil,
        onCompletion: ((ImageTask) -> Void)? = nil
    ) {
        self.prompt = prompt
        self.mode = mode
        self.config = config
        self.onCompletion = onCompletion
        
        // Start processing immediately
        Task {
            await process(inputImage: inputImage)
        }
    }
    
    // MARK: - Processing
    
    private func process(inputImage: Data?) async {
        do {
            let imageData: Data
            
            switch mode {
            case .create:
                imageData = try await generateImage(prompt: prompt, config: config)
            case .edit:
                imageData = try await editImage(prompt: prompt, config: config, inputImage: inputImage)
            }
            
            await updateState(imageData: imageData, error: nil)
        } catch {
            await updateState(imageData: nil, error: error.localizedDescription)
        }
    }
    
    @MainActor
    private func updateState(imageData: Data?, error: String?) {
        self.imageData = imageData
        self.error = error
        self.isProcessing = false
        onCompletion?(self)
    }
    
    private func generateImage(prompt: String, config: ImageConfig) async throws -> Data {
        let urls = try await ImageGenerationService.generateImages(
            prompt: prompt,
            model: config.generationModel
        )
        
        guard let firstURL = urls.first else {
            throw GenerationError.noImageGenerated
        }
        
        let (data, _) = try await URLSession.shared.data(from: firstURL)
        return data
    }
    
    private func editImage(prompt: String, config: ImageConfig, inputImage: Data?) async throws -> Data {
        guard let imageData = inputImage else {
            throw GenerationError.noInputImage
        }
        
        let base64String = imageData.base64EncodedString()
        let imageURLString = "data:image/png;base64,\(base64String)"
        
        let urls = try await ImageEditingService.editImages(
            using: config.editModel,
            prompt: prompt,
            imageURLs: [imageURLString]
        )
        
        guard let editedURL = urls.first else {
            throw GenerationError.noEditedImageReturned
        }
        
        let (data, _) = try await URLSession.shared.data(from: editedURL)
        return data
    }
}
