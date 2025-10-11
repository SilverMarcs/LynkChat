//
//  ImageEditingService.swift
//  LynkChat
//
//  Created by GitHub Copilot on 11/10/2025.
//

import Foundation

enum ImageEditingService {
    /// Unified entry point for editing.
    static func editImages(using model: ImageEditingModel, allHistory: [Generation]) async throws -> [Data] {
        // Latest generation contains the current prompt
        guard let latest = allHistory.last else {
            throw RuntimeError("No generation history available")
        }

        let prompt = latest.config.prompt
        let previousOutputs = allHistory.flatMap { $0.images + $0.inputImages }

        switch model {
        case .seedream:
            return try await editWithSeedream(prompt: prompt, images: previousOutputs)
        case .nanoBanana:
            return try await editWithNanoBanana(prompt: prompt, images: previousOutputs)
        case .qwen:
            return try await editWithQwenPlus(prompt: prompt, images: previousOutputs)
        case .gpt:
            // GPT Image 1 expects a single image input. Prefer any user-provided inputImages
            // attached to the latest generation; otherwise fall back to previous outputs.
            let imageData = latest.inputImages.first ?? previousOutputs.first
            guard let imageData = imageData else {
                throw RuntimeError("No input image provided for GPT editing")
            }
            
            return try await editWithGpt(prompt: prompt, image: imageData)
        }
    }
    
    private static func editWithSeedream(prompt: String, images: [Data]) async throws -> [Data] {
        let imageUrls = images.compactMap { data -> String? in
            "data:image/png;base64,\(data.base64EncodedString())"
        }
        
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "images": imageUrls,
//            "size": "2048*3072",
            "enable_sync_mode": true,
            "enable_base64_output": true
        ]
        
        return try await performEditRequest(path: ImageEditingModel.seedream.apiPath, body: requestBody)
    }
    
    private static func editWithNanoBanana(prompt: String, images: [Data]) async throws -> [Data] {
        let imageUrls = images.compactMap { data -> String? in
            "data:image/png;base64,\(data.base64EncodedString())"
        }
        
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "images": imageUrls,
//            "aspect_ratio": "9:16",
            "output_format": "jpeg",
            "enable_sync_mode": true,
            "enable_base64_output": true
        ]
        
        return try await performEditRequest(path: ImageEditingModel.nanoBanana.apiPath, body: requestBody)
    }
    
    
    private static func editWithGpt(prompt: String, image: Data) async throws -> [Data] {
        let imageUrl = "data:image/png;base64,\(image.base64EncodedString())"

        let requestBody: [String: Any] = [
            "prompt": prompt,
            "image": imageUrl,
            "quality": "medium",
            "enable_sync_mode": true,
            "enable_base64_output": true
        ]

        return try await performEditRequest(path: ImageEditingModel.gpt.apiPath, body: requestBody)
    }
    
    private static func editWithQwenPlus(prompt: String, images: [Data]) async throws -> [Data] {
        let imageUrls = images.compactMap { data -> String? in
            "data:image/png;base64,\(data.base64EncodedString())"
        }
        
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "images": imageUrls,
//            "size": "1024*1024",
            "seed": -1,
            "output_format": "jpeg",
            "enable_sync_mode": true,
            "enable_base64_output": true
        ]
        
        return try await performEditRequest(path: ImageEditingModel.qwen.apiPath, body: requestBody)
    }
    
    private static func performEditRequest(path: String, body: [String: Any]) async throws -> [Data] {
        guard let url = URL(string: "https://api.wavespeed.ai\(path)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ImageConfigDefaults().wavespeedApiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RuntimeError("Invalid response")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw RuntimeError("Image editing failed: \(errorText)")
        }
        
        // Parse response
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let responseData = json?["data"] as? [String: Any],
              let outputs = responseData["outputs"] as? [String] else {
            throw RuntimeError("Invalid response format")
        }
        
        // Decode base64 images
        return outputs.compactMap { base64String -> Data? in
            Data(base64Encoded: base64String)
        }
    }
}
