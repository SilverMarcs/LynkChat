//
//  APIService+Image.swift
//  LynkChat
//
//  Created by Zabir Raihan on 27/08/2025.
//

import Foundation

extension APIService {
    static func generateImages(config: ImageConfig) async throws -> [Data] {
        let requestBody = ImageGenerationRequest(
            prompt: config.prompt,
            model: config.model.id,
            n: config.numImages
        )
        
        guard var request = makeRequest(path: .image, method: .POST) else {
            throw URLError(.badURL)
        }
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try handleAPIResponse(data: data, response: response, context: "Image generation")
        
        let apiResponse = try JSONDecoder().decode(ImageGenerationResult.self, from: data)
        
        return try apiResponse.images.map { imageData in
            guard let data = imageData.imageData else {
                throw RuntimeError("Invalid base64 data")
            }
            return data
        }
    }
}
