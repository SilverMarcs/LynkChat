//
//  ImageGenerator.swift
//  LynkChat
//
//  Created by Zabir Raihan on 15/09/2024.
//

import Foundation
import SwiftData

struct ImageGenerator {
    struct GenerationParameters: Codable {
        let prompt: String
        let n: Int
    }
    
    struct ImageResponse: Codable {
            let created: Int?
            let data: [ImageData]
        }
        
        struct ImageData: Codable {
            let url: String
        }
        
        static func generateImages(config: ImageConfig) async throws -> [Data] {
            // Construct URL from provider host
            guard let url = URL(string: "https://\(config.provider.baseUrl)/images/generations") else {
                throw URLError(.badURL)
            }
            
            // Prepare request body
            let requestBody: [String: Any] = [
                "model": config.model.code,
                "prompt": config.prompt,
                "n": config.numImages,
                "size": "1024x1024" // Using default size for now
            ]
            
            // Create request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(config.provider.apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            // Make request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check response status
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            // Decode response
            let imageResponse = try JSONDecoder().decode(ImageResponse.self, from: data)
            
            // Download all images
            var imageDataArray: [Data] = []
            
            for imageData in imageResponse.data {
                guard let imageUrl = URL(string: imageData.url) else { continue }
                let (imageData, _) = try await URLSession.shared.data(from: imageUrl)
                imageDataArray.append(imageData)
            }
            
            return imageDataArray
        }
}
