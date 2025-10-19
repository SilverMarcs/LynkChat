import Foundation

enum ImageGenerationService {
    static func generateImages(config: ImageConfig) async throws -> [Data] {
        let wavespeedApiKey = ImageConfigDefaults().wavespeedApiKey
        
        guard !wavespeedApiKey.isEmpty else {
            throw RuntimeError("Wavespeed API key not configured")
        }
        
        switch config.model {
        case .nanoBanana:
            return try await NanoBananaGenerator.generate(
                prompt: config.prompt,
                apiKey: wavespeedApiKey
            )
        case .seedream:
            return try await SeedreamV4Generator.generate(
                prompt: config.prompt,
                apiKey: wavespeedApiKey
            )
        case .gpt:
            return try await GPTImageGenerator.generate(
                prompt: config.prompt,
                apiKey: wavespeedApiKey
            )
        }
    }
}

enum NanoBananaGenerator {
    static func generate(
        prompt: String,
        aspectRatio: String = "9:16",
        outputFormat: String = "png",
        apiKey: String
    ) async throws -> [Data] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/google/nano-banana/text-to-image")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "aspect_ratio": aspectRatio,
            "output_format": outputFormat,
            "enable_base64_output": true,
            "enable_sync_mode": true
        ]
        
        let outputs = try await submitRequest(url: url, body: body, apiKey: apiKey)
        
        return try outputs.map { output in
            let stripped = stripDataUrlPrefix(output)
            guard let imageData = Data(base64Encoded: stripped) else {
                throw RuntimeError("Failed to decode base64 image")
            }
            return imageData
        }
    }
}

enum SeedreamV4Generator {
    static func generate(
        prompt: String,
        size: String = "1024*1536",
        apiKey: String
    ) async throws -> [Data] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/bytedance/seedream-v4")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "size": size,
            "enable_base64_output": true,
            "enable_sync_mode": false
        ]
        
        let requestId = try await submitTask(url: url, body: body, apiKey: apiKey)
        let outputs = try await pollForResult(requestId: requestId, apiKey: apiKey)
        
        return try outputs.map { output in
            let stripped = stripDataUrlPrefix(output)
            guard let imageData = Data(base64Encoded: stripped) else {
                throw RuntimeError("Failed to decode base64 image")
            }
            return imageData
        }
    }
}

enum GPTImageGenerator {
    static func generate(
        prompt: String,
        quality: String = "medium",
        size: String = "1024*1536",
        apiKey: String
    ) async throws -> [Data] {
        let url = URL(string: "https://api.wavespeed.ai/api/v3/openai/gpt-image-1/text-to-image")!
        
        let body: [String: Any] = [
            "prompt": prompt,
            "quality": quality,
            "size": size,
            "enable_base64_output": true,
            "enable_sync_mode": true,
            "num_images": 1
        ]
        
        let outputs = try await submitRequest(url: url, body: body, apiKey: apiKey)
        
        return try outputs.map { output in
            let stripped = stripDataUrlPrefix(output)
            guard let imageData = Data(base64Encoded: stripped) else {
                throw RuntimeError("Failed to decode base64 image")
            }
            return imageData
        }
    }
}

private func submitRequest(url: URL, body: [String: Any], apiKey: String) async throws -> [String] {
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

private func submitTask(url: URL, body: [String: Any], apiKey: String) async throws -> String {
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
        throw RuntimeError("Task submission failed: \(httpResponse.statusCode), \(errorText)")
    }
    
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    guard let responseData = json?["data"] as? [String: Any],
          let requestId = responseData["id"] as? String else {
        let responseText = String(data: data, encoding: .utf8) ?? "Unable to decode"
        throw RuntimeError("No request ID in response: \(responseText)")
    }
    
    return requestId
}

private func pollForResult(
    requestId: String,
    apiKey: String,
    maxAttempts: Int = 60,
    intervalMs: Int = 250
) async throws -> [String] {
    let url = URL(string: "https://api.wavespeed.ai/api/v3/predictions/\(requestId)/result")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    for _ in 1...maxAttempts {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RuntimeError("Invalid response")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw RuntimeError("Polling failed: \(httpResponse.statusCode), \(errorText)")
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let responseData = json?["data"] as? [String: Any] else {
            let responseText = String(data: data, encoding: .utf8) ?? "Unable to decode"
            throw RuntimeError("Invalid response format: \(responseText)")
        }
        
        let status = responseData["status"] as? String ?? "unknown"
        
        switch status {
        case "completed":
            guard let outputs = responseData["outputs"] as? [String], !outputs.isEmpty else {
                throw RuntimeError("No outputs in completed response")
            }
            return outputs
            
        case "failed":
            let error = responseData["error"] as? String ?? "Unknown error"
            throw RuntimeError("Task failed: \(error)")
            
        case "processing", "created":
            try await Task.sleep(nanoseconds: UInt64(intervalMs) * 1_000_000)
            
        default:
            throw RuntimeError("Unknown status: \(status)")
        }
    }
    
    throw RuntimeError("Polling timeout after \(maxAttempts) attempts")
}

private func stripDataUrlPrefix(_ dataUrl: String) -> String {
    if let range = dataUrl.range(of: "base64,") {
        return String(dataUrl[range.upperBound...])
    }
    return dataUrl
}
