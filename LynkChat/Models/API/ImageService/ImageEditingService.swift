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
                "enable_base64_output": true
            ]

        case .nanoBanana:
            apiPath = model.apiPath
            requestBody = [
                "prompt": prompt,
                "images": convertToBase64URLs(inputImages),
                "output_format": "jpeg",
                "enable_sync_mode": true,
                "enable_base64_output": true
            ]
        case .qwen:
            apiPath = model.apiPath
            requestBody = [
                "prompt": prompt,
                "images": convertToBase64URLs(inputImages),
                "seed": -1,
                "output_format": "jpeg",
                "enable_sync_mode": true,
                "enable_base64_output": true
            ]
        }

        // Submit task and poll for result
        return try await submitAndPollTask(path: apiPath, body: requestBody)
    }
    
    // MARK: - Helper Functions
    
    private static func convertToBase64URLs(_ images: [Data]) -> [String] {
        images.map { "data:image/png;base64,\($0.base64EncodedString())" }
    }
    
    private static func submitAndPollTask(path: String, body: [String: Any]) async throws -> [Data] {
        // Step 1: Submit the task
        let requestId = try await submitTask(path: path, body: body)
        
        // Step 2: Poll for the result
        return try await pollForResult(requestId: requestId)
    }
    
    private static func submitTask(path: String, body: [String: Any]) async throws -> String {
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
            throw RuntimeError("Failed to submit task: \(errorText)")
        }
        
        // Parse response
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let responseData = json?["data"] as? [String: Any],
              let requestId = responseData["id"] as? String else {
            let responseText = String(data: data, encoding: .utf8) ?? "Unable to decode"
            throw RuntimeError("No requestId in response: \(responseText)")
        }
        
        return requestId
    }
    
    private static func pollForResult(
        requestId: String,
        maxAttempts: Int = 60,
        delaySeconds: UInt64 = 2
    ) async throws -> [Data] {
        guard let url = URL(string: "https://api.wavespeed.ai/api/v3/predictions/\(requestId)/result") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(ImageConfigDefaults().wavespeedApiKey)", forHTTPHeaderField: "Authorization")
        
        for _ in 1...maxAttempts {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RuntimeError("Invalid response")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw RuntimeError("Failed to query result: \(errorText)")
            }
            
            // Parse response
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let responseData = json?["data"] as? [String: Any] else {
                let responseText = String(data: data, encoding: .utf8) ?? "Unable to decode"
                throw RuntimeError("Invalid response format: \(responseText)")
            }
            
            let status = responseData["status"] as? String ?? "unknown"
            
            switch status {
            case "completed":
                // Extract and decode outputs
                guard let outputs = responseData["outputs"] as? [String], !outputs.isEmpty else {
                    throw RuntimeError("No outputs in completed response")
                }
                
                // Try to decode as base64, if that fails assume they're URLs and download
                var images: [Data] = []
                for output in outputs {
                    if let imageData = Data(base64Encoded: output) {
                        images.append(imageData)
                    } else if let url = URL(string: output) {
                        let (downloadedData, _) = try await URLSession.shared.data(from: url)
                        images.append(downloadedData)
                    }
                }
                
                if images.isEmpty {
                    throw RuntimeError("No valid images in outputs")
                }
                
                return images
                
            case "failed":
                let error = responseData["error"] as? String ?? "Unknown error"
                throw RuntimeError("Task failed: \(error)")
                
            case "processing", "created":
                try await Task.sleep(nanoseconds: delaySeconds * 1_000_000_000)
                
            default:
                throw RuntimeError("Unknown status: \(status)")
            }
        }
        
        throw RuntimeError("Polling timeout after \(maxAttempts) attempts")
    }
}
