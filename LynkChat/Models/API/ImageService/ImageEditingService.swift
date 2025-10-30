//
//  ImageEditingService.swift
//  LynkChat
//
//  Created by GitHub Copilot on 11/10/2025.
//

import Foundation

enum ImageEditingService {
    /// Edit images strictly using provided input images and prompt.
    static func editImages(using model: ImageEditingModel, prompt: String, inputImages: [Data]) async throws -> [Data] {
        guard !inputImages.isEmpty else {
            throw RuntimeError("No input images provided for editing")
        }

        // Build request body based on model
        let requestBody: [String: Any]
        let apiPath: String

        switch model {
        case .seedream:
            apiPath = model.apiPath
            requestBody = [
                "prompt": prompt,
                "images": convertToBase64URLs(inputImages),
                "enable_sync_mode": true,
                "enable_base64_output": false
            ]

        case .nanoBanana:
            apiPath = model.apiPath
            requestBody = [
                "prompt": prompt,
                "images": convertToBase64URLs(inputImages),
                "output_format": "jpeg",
                "enable_sync_mode": true,
                "enable_base64_output": false
            ]
            
        case .qwen:
            apiPath = model.apiPath
            requestBody = [
                "prompt": prompt,
                "images": convertToBase64URLs(inputImages),
                "seed": -1,
                "output_format": "jpeg",
                "enable_sync_mode": true,
                "enable_base64_output": false
            ]
        }

        // Submit task and get result directly (sync mode)
        return try await submitTaskSync(path: apiPath, body: requestBody)
    }
    
    // MARK: - Helper Functions
    
    private static func convertToBase64URLs(_ images: [Data]) -> [String] {
        images.map { "data:image/png;base64,\($0.base64EncodedString())" }
    }
    
    private static func submitTaskSync(path: String, body: [String: Any]) async throws -> [Data] {
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
            throw RuntimeError("Failed to edit images: \(errorText)")
        }
        
        // Parse response - in sync mode, outputs are returned directly as URLs
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let responseData = json?["data"] as? [String: Any],
              let outputs = responseData["outputs"] as? [String], !outputs.isEmpty else {
            let responseText = String(data: data, encoding: .utf8) ?? "Unable to decode"
            throw RuntimeError("No outputs in response: \(responseText)")
        }
        
        // Download images from URLs
        var images: [Data] = []
        for output in outputs {
            guard let imageURL = URL(string: output) else {
                throw RuntimeError("Invalid image URL: \(output)")
            }
            let (imageData, _) = try await URLSession.shared.data(from: imageURL)
            images.append(imageData)
        }
        
        if images.isEmpty {
            throw RuntimeError("No valid images downloaded")
        }
        
        return images
    }
}
