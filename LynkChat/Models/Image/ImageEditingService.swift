//
//  ImageEditingService.swift
//  LynkChat
//
//  Created by GitHub Copilot on 11/10/2025.
//

import SwiftUI

enum ImageEditingService {
    static func editImages(using model: ImageEditingModel, allHistory: [Generation]) async throws -> [Data] {
        guard let latest = allHistory.last else {
            throw RuntimeError("No generation history available")
        }

        let prompt = latest.config.prompt
        
        var previousOutputs: [Data] = []
        if allHistory.count >= 2 {
            let secondLast = allHistory[allHistory.count - 2]
            previousOutputs = secondLast.images.isEmpty ? secondLast.inputImages : secondLast.images
        }
        
        if !latest.inputImages.isEmpty {
            previousOutputs.append(contentsOf: latest.inputImages)
        }
        
        switch model {
        case .seedream:
            return try await SeedreamV4Editor.edit(prompt: prompt, images: previousOutputs)
        case .nanoBanana:
            return try await NanoBananaEditor.edit(prompt: prompt, images: previousOutputs)
        case .qwen:
            return try await QwenEditor.edit(prompt: prompt, images: previousOutputs)
        }
    }
}

enum SeedreamV4Editor {
    static func edit(prompt: String, images: [Data]) async throws -> [Data] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/bytedance/seedream-v4/edit")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "images": convertToBase64URLs(images),
            "size": ImageEditingService.inferredSizeString(from: images.first ?? Data()) ?? "2176*3840",
            "enable_sync_mode": true,
            "enable_base64_output": true
        ]
        
        let outputs = try await submitRequest(url: url, body: body)
        return try decodeOutputs(outputs)
    }
}

enum NanoBananaEditor {
    static func edit(prompt: String, images: [Data]) async throws -> [Data] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/google/nano-banana/edit")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "images": convertToBase64URLs(images),
            "output_format": "jpeg",
            "enable_sync_mode": true,
            "enable_base64_output": true
        ]
        
        let outputs = try await submitRequest(url: url, body: body)
        return try decodeOutputs(outputs)
    }
}

enum QwenEditor {
    static func edit(prompt: String, images: [Data]) async throws -> [Data] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/wavespeed-ai/qwen-image/edit")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "image": convertToBase64URLs(images).first!,
            "seed": -1,
            "output_format": "jpeg",
            "enable_sync_mode": true,
            "enable_base64_output": true
        ]
        
        let outputs = try await submitRequest(url: url, body: body)
        return try decodeOutputs(outputs)
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


extension ImageEditingService {
    static func inferredSizeString(from imageData: Data) -> String? {
        #if canImport(UIKit)
        guard let image = UIImage(data: imageData) else { return nil }
        let width = image.size.width * image.scale
        let height = image.size.height * image.scale
        #elseif canImport(AppKit)
        guard let image = NSImage(data: imageData),
              let rep = image.representations.first else { return nil }
        let width = Double(rep.pixelsWide)
        let height = Double(rep.pixelsHigh)
        #endif
        
        guard width > 0, height > 0 else { return nil }
        
        let aspect = width / height
        
        var scaledWidth = width
        var scaledHeight = height
        
        if scaledWidth > 4096 || scaledHeight > 4096 {
            if aspect >= 1 {
                scaledWidth = 4096
                scaledHeight = 4096 / aspect
            } else {
                scaledHeight = 4096
                scaledWidth = 4096 * aspect
            }
        }
        
        let finalW = Int(round(scaledWidth / 2) * 2)
        let finalH = Int(round(scaledHeight / 2) * 2)
        
        return "\(finalW)*\(finalH)"
    }
}
