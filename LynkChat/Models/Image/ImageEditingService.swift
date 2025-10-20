//
//  ImageEditingService.swift
//  LynkChat
//
//  Created by GitHub Copilot on 11/10/2025.
//

import SwiftUI

enum ImageEditingService {
    static func editImages(using model: ImageEditingModel, allHistory: [Generation]) async throws -> [URL] {
        guard let latest = allHistory.last else {
            throw RuntimeError("No generation history available")
        }

        let prompt = latest.config.prompt
        
        var imageList: [String] = []
        if allHistory.count >= 2 {
            let secondLast = allHistory[allHistory.count - 2]
            imageList = secondLast.imageURLs.map { $0.absoluteString }
        }
        
        if !latest.imageURLs.isEmpty {
            imageList.append(contentsOf: latest.imageURLs.map { $0.absoluteString })
        }
        
        switch model {
        case .seedream:
            return try await SeedreamV4Editor.edit(prompt: prompt, imageURLs: imageList)
        case .nanoBanana:
            return try await NanoBananaEditor.edit(prompt: prompt, imageURLs: imageList)
        case .qwen:
            return try await QwenEditor.edit(prompt: prompt, imageURLs: imageList)
        }
    }
}

enum SeedreamV4Editor {
    static func edit(prompt: String, imageURLs: [String]) async throws -> [URL] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/bytedance/seedream-v4/edit")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "images": imageURLs,
            "size": "2176*3840",
            "enable_sync_mode": true,
            "enable_base64_output": false
        ]
        
        let outputs = try await submitRequest(url: url, body: body)
        return outputs.compactMap { URL(string: $0) }
    }
}

enum NanoBananaEditor {
    static func edit(prompt: String, imageURLs: [String]) async throws -> [URL] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/google/nano-banana/edit")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "images": imageURLs,
            "output_format": "jpeg",
            "enable_sync_mode": true,
            "enable_base64_output": false
        ]
        
        let outputs = try await submitRequest(url: url, body: body)
        return outputs.compactMap { URL(string: $0) }
    }
}

enum QwenEditor {
    static func edit(prompt: String, imageURLs: [String]) async throws -> [URL] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/wavespeed-ai/qwen-image/edit")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "image": imageURLs.first ?? "",
            "seed": -1,
            "output_format": "jpeg",
            "enable_sync_mode": true,
            "enable_base64_output": false
        ]
        
        let outputs = try await submitRequest(url: url, body: body)
        return outputs.compactMap { URL(string: $0) }
    }
}

private func submitRequest(url: URL, body: [String: Any]) async throws -> [String] {
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
          let outputs = responseData["outputs"] as? [String], !outputs.isEmpty else {
        throw RuntimeError("No outputs returned")
    }
    
    return outputs
}

private func decodeOutputs(_ outputs: [String]) throws -> [Data] {
    try outputs.map { output in
        let stripped = stripDataUrlPrefix(output)
        guard let imageData = Data(base64Encoded: stripped) else {
            throw RuntimeError("Failed to decode base64 image")
        }
        return imageData
    }
}

private func stripDataUrlPrefix(_ dataUrl: String) -> String {
    if let range = dataUrl.range(of: "base64,") {
        return String(dataUrl[range.upperBound...])
    }
    return dataUrl
}

private func convertToBase64URLs(_ images: [Data]) -> [String] {
    images.map { "data:image/png;base64,\($0.base64EncodedString())" }
}
