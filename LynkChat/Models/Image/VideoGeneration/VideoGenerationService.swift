//
//  VideoGenerationService.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/10/2025.
//

import Foundation

enum VideoGenerationService {
    static func generateVideos(prompt: String, imageURLs: [String]) async throws -> [URL] {
        return try await SeedanceVideoGenerator.generate(prompt: prompt, imageURLs: imageURLs)
    }
}

enum SeedanceVideoGenerator {
    static func generate(prompt: String, imageURLs: [String]) async throws -> [URL] {
        let submitURL = URL(string: "https://api.wavespeed.ai/api/v3/bytedance/seedance-v1-lite-i2v-720p")!
        
        var body: [String: Any] = [
            "camera_fixed": false,
            "seed": -1,
            "duration": 5
        ]
        
        if !prompt.isEmpty {
            body["prompt"] = prompt
        }
        
        if !imageURLs.isEmpty {
            body["image"] = imageURLs.first
        }
        
        // Step 1: Submit the task
        let requestId = try await submitTask(url: submitURL, body: body)
        
        // Step 2: Poll for results
        let outputs = try await pollForResult(requestId: requestId)
        
        return outputs.compactMap { URL(string: $0) }
    }
}

private func submitTask(url: URL, body: [String: Any]) async throws -> String {
    let apiKey = ImageConfigDefaults().wavespeedApiKey
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw RuntimeError("Invalid response")
    }
    
    if !(200...299).contains(httpResponse.statusCode) {
        let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
        throw RuntimeError("Request failed: \(httpResponse.statusCode), \(errorText)")
    }
    
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    guard let responseData = json?["data"] as? [String: Any],
          let requestId = responseData["id"] as? String else {
        throw RuntimeError("No request ID returned")
    }
    
    return requestId
}

private func pollForResult(requestId: String, maxAttempts: Int = 60, delaySeconds: UInt64 = 5) async throws -> [String] {
    let apiKey = ImageConfigDefaults().wavespeedApiKey
    let resultURL = URL(string: "https://api.wavespeed.ai/api/v3/predictions/\(requestId)/result")!
    
    var request = URLRequest(url: resultURL)
    request.httpMethod = "GET"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    for attempt in 1...maxAttempts {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RuntimeError("Invalid response")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw RuntimeError("Request failed: \(httpResponse.statusCode), \(errorText)")
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let responseData = json?["data"] as? [String: Any],
              let status = responseData["status"] as? String else {
            throw RuntimeError("Invalid response format")
        }
        
        switch status {
        case "completed":
            guard let outputs = responseData["outputs"] as? [String], !outputs.isEmpty else {
                throw RuntimeError("No outputs returned")
            }
            return outputs
            
        case "failed":
            let error = responseData["error"] as? String ?? "Unknown error"
            throw RuntimeError("Video generation failed: \(error)")
            
        case "created", "processing":
            // Continue polling
            if attempt < maxAttempts {
                try await Task.sleep(nanoseconds: delaySeconds * 1_000_000_000)
            }
            
        default:
            throw RuntimeError("Unknown status: \(status)")
        }
    }
    
    throw RuntimeError("Timeout: Video generation took too long")
}
