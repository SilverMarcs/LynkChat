import Foundation

enum ImageGenerationService {
    static func generateImages(config: ImageConfig) async throws -> [Data] {
        switch config.model {
        case .nanoBanana:
            return try await NanoBananaGenerator.generate(prompt: config.prompt)
        case .seedream:
            return try await SeedreamV4Generator.generate(prompt: config.prompt)
        case .gpt:
            return try await GPTImageGenerator.generate(prompt: config.prompt)
        }
    }
}

enum NanoBananaGenerator {
    static func generate(prompt: String) async throws -> [Data] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/google/nano-banana/text-to-image")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "aspect_ratio": "9:16",
            "output_format": "jpeg",
            "enable_base64_output": true,
            "enable_sync_mode": true
        ]
        
        let outputs = try await submitRequest(url: url, body: body)
        return try decodeOutputs(outputs)
    }
}

enum SeedreamV4Generator {
    static func generate(prompt: String) async throws -> [Data] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/bytedance/seedream-v4")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "size": "2176*3840",
            "enable_base64_output": true,
            "enable_sync_mode": true
        ]
        
        let outputs = try await submitRequest(url: url, body: body)
        return try decodeOutputs(outputs)
    }
}

enum GPTImageGenerator {
    static func generate(prompt: String) async throws -> [Data] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/openai/gpt-image-1/text-to-image")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "quality": "medium",
            "size": "1024*1536",
            "enable_base64_output": true,
            "enable_sync_mode": true,
            "num_images": 1
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
