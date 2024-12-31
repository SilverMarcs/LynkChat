//
//  ImageGenerator.swift
//  LynkChat
//
//  Created by Zabir Raihan on 15/09/2024.
//

import Foundation

enum ImageGenerator {
    static func generateImages(config: ImageConfig) async throws -> [Data] {
            // Construct the URL
            guard let url = URL(string: "\(String.apiHost)/image") else {
                throw ImageAPIError.invalidURL
            }
            
            // Prepare the request body
            let requestBody = [
                "prompt": config.prompt,
                "model": config.model.id,
                "n": config.numImages
            ] as [String: Any]
            
            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(AppConfig.shared.myApiKey, forHTTPHeaderField: "x-api-key")
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Check for HTTP status code
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ImageAPIError.serverError("Invalid response")
                }
                
                if httpResponse.statusCode != 200 {
                    throw RuntimeError("Server returned status code \(httpResponse.statusCode)")
                }
                
                // Decode the response
                let apiResponse = try JSONDecoder().decode(ImageAPIResponse.self, from: data)
                
                // Download all images
                let imageDataArray = try await withThrowingTaskGroup(of: Data.self) { group in
                    var results: [Data] = []
                    
                    for imageData in apiResponse.data {
                        group.addTask {
                            let (imageData, _) = try await URLSession.shared.data(from: URL(string: imageData.url)!)
                            return imageData
                        }
                    }
                    
                    for try await imageData in group {
                        results.append(imageData)
                    }
                    
                    return results
                }
                
                return imageDataArray
                
            } catch {
                if let decodingError = error as? DecodingError {
                    throw ImageAPIError.decodingError(decodingError)
                }
                throw ImageAPIError.networkError(error)
            }
        }
}

struct ImageResponseData: Codable {
    let url: String
}

struct ImageAPIResponse: Codable {
    let data: [ImageResponseData]
}

// Error handling
enum ImageAPIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
}
