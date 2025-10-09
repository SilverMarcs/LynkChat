//
//  APIService+Wavespeed.swift
//  LynkChat
//
//  Created by Zabir Raihan on 09/10/2025.
//

import Foundation

struct APIService {
    static func generateImageWithWavespeed(prompt: String, numImages: Int) async throws -> [Data] {
        guard let apiKey = UserDefaults.standard.string(forKey: "wavespeedApiKey"), !apiKey.isEmpty else {
            throw RuntimeError("Wavespeed API key not configured")
        }
        
        let url = URL(string: "https://api.wavespeed.ai/api/v3/google/nano-banana/text-to-image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "enable_base64_output": false,
            "enable_sync_mode": true,
            "output_format": "png",
            "prompt": prompt,
            "num_images": numImages
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataObj = json["data"] as? [String: Any],
              let outputs = dataObj["outputs"] as? [String] else {
            throw RuntimeError("Invalid response from Wavespeed API")
        }
        
        var imageDataArray: [Data] = []
        for imageUrl in outputs {
            guard let url = URL(string: imageUrl) else { continue }
            if let (imageData, _) = try? await URLSession.shared.data(from: url) {
                imageDataArray.append(imageData)
            }
        }
        
        return imageDataArray
    }
    static func editImageWithWavespeed(prompt: String, images: [Data], contextPrompts: [String], numImages: Int) async throws -> [Data] {
        guard let apiKey = UserDefaults.standard.string(forKey: "wavespeedApiKey"), !apiKey.isEmpty else {
            throw RuntimeError("Wavespeed API key not configured")
        }

        // Convert images to base64
        let imageList = images.map { $0.base64EncodedString() }
        guard !imageList.isEmpty else {
            throw RuntimeError("No images provided for editing")
        }

        // Build context prompt from history
        let contextPrompt = contextPrompts.joined(separator: "\n")
        let fullPrompt = contextPrompt.isEmpty ? prompt : "\(contextPrompt)\n\nEdit instruction: \(prompt)"

        let url = URL(string: "https://api.wavespeed.ai/api/v3/bytedance/seedream-v4/edit")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        var body: [String: Any] = [
            "size": "2048*2048",
            "enable_sync_mode": true,
            "enable_base64_output": false,
            "images": imageList,
            "prompt": fullPrompt
        ]

        // include optional parameters if desired
        if numImages > 0 {
            body["num_images"] = numImages
        }
        // keep output_format if you want a specific format (png/jpg)
        body["output_format"] = "png"

        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResp = response as? HTTPURLResponse, !(200...299).contains(httpResp.statusCode) {
            let bodyText = String(data: data, encoding: .utf8) ?? "<non-text response>"
            throw RuntimeError("Wavespeed API error: status \(httpResp.statusCode): \(bodyText)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataObj = json["data"] as? [String: Any],
              let outputs = dataObj["outputs"] as? [String] else {
            throw RuntimeError("Invalid response from Wavespeed API")
        }

        var imageDataArray: [Data] = []
        for imageUrl in outputs {
            guard let url = URL(string: imageUrl) else { continue }
            let (imageData, _) = try await URLSession.shared.data(from: url)
            imageDataArray.append(imageData)
        }

        return imageDataArray
    }
}
