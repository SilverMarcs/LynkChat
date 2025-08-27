//
//  ImageGenerator.swift
//  LynkChat
//
//  Created by Zabir Raihan on 15/09/2024.
//

import Foundation

// TODO: move to apiservice struct
enum ImageGenerator {
    static func generateImages(config: ImageConfig) async throws -> [Data] {
        // Create the request body
        let requestBody = ImageGenerationRequest(
            prompt: config.prompt,
            model: config.model.id,
            n: config.numImages
        )
        
        // Create the request using APIService
        guard var request = APIService.makeRequest(path: .image, method: .POST) else {
            throw ImageAPIError.invalidURL
        }
        
        // Set the request body
        request.httpBody = try? JSONEncoder().encode(requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check for HTTP status code
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageAPIError.serverError("Invalid response")
            }
            
            if httpResponse.statusCode != 200 {
                // Try to decode error response
                let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw RuntimeError(errorResponse.error)
            }
            
            // Decode the success response
            let apiResponse = try JSONDecoder().decode(ImageToolResult.self, from: data)
            
            // Decode all base64 images
            let imageDataArray = try apiResponse.images.map { data in
                guard let data = data.imageData else {
                    throw ImageAPIError.decodingError(NSError(domain: "ImageGenerator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid base64 data"]))
                }
                return data
            }
            
            return imageDataArray
            
        } catch {
            if let runtimeError = error as? RuntimeError {
                throw runtimeError
            }
            if let decodingError = error as? DecodingError {
                throw ImageAPIError.decodingError(decodingError)
            }
            throw ImageAPIError.networkError(error)
        }
    }
}



// Error handling
enum ImageAPIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
}
