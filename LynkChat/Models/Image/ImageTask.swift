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
    @Transient var config: ImageConfigDefaults?
    @Transient var inputImageData: Data?
    
    init(prompt: String, mode: GenerationMode, config: ImageConfigDefaults, inputImageData: Data? = nil) {
        self.prompt = prompt
        self.mode = mode
        self.config = config
        self.inputImageData = inputImageData
        
        // Start processing immediately
        Task {
            await process()
        }
    }
    
    // MARK: - Processing
    
    private func process() async {
        guard let config = config else {
            updateState(imageData: nil, error: "Configuration not available")
            return
        }
        
        do {
            let imageData: Data
            
            switch mode {
            case .create:
                imageData = try await generateImage(prompt: prompt, config: config)
            case .edit:
                imageData = try await editImage(prompt: prompt, config: config)
            }
            
            updateState(imageData: imageData, error: nil)
        } catch {
            updateState(imageData: nil, error: error.localizedDescription)
        }
    }
    
    private func updateState(imageData: Data?, error: String?) {
        self.imageData = imageData
        self.error = error
        self.isProcessing = false
    }
    
    private func generateImage(prompt: String, config: ImageConfigDefaults) async throws -> Data {
        let urls = try await ImageGenerationService.generateImages(
            prompt: prompt,
            model: config.defaultModel
        )
        
        guard let firstURL = urls.first else {
            throw GenerationError.noImageGenerated
        }
        
        let (data, _) = try await URLSession.shared.data(from: firstURL)
        return data
    }
    
    private func editImage(prompt: String, config: ImageConfigDefaults) async throws -> Data {
        guard let imageData = inputImageData else {
            throw GenerationError.noInputImage
        }
        
        let base64String = imageData.base64EncodedString()
        let imageURLString = "data:image/png;base64,\(base64String)"
        
        let urls = try await ImageEditingService.editImages(
            using: config.defaultEditingModel,
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
