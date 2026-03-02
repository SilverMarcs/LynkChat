//
//  WaveSpeedImageService.swift
//  LynkChat
//
//  Created by Codex on 03/02/2026.
//

import Foundation

enum WaveSpeedImageService {
    private static let baseURL = "https://api.wavespeed.ai"
    private static let predictionResultPath = "/api/v3/predictions"
    private static let pollDelayNanoseconds: UInt64 = 1_000_000_000
    private static let maxPollAttempts = 60

    static func performImageRequest(path: String, body: [String: Any]) async throws -> [Data] {
        let response = try await submitRequest(path: path, body: body)

        if let outputs = response.data.outputs, !outputs.isEmpty {
            return try await downloadImages(from: outputs)
        }

        if response.data.isTerminalFailure {
            throw RuntimeError(response.data.error ?? response.message ?? "Image request failed")
        }

        guard let predictionID = response.data.id, !predictionID.isEmpty else {
            throw RuntimeError(response.message ?? "Missing prediction id")
        }

        return try await pollForImages(predictionID: predictionID)
    }

    private static func submitRequest(path: String, body: [String: Any]) async throws -> WaveSpeedPredictionResponse {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ImageConfigDefaults().wavespeedApiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateHTTPResponse(data: data, response: response, fallbackContext: "Image request")

        let decoded = try JSONDecoder().decode(WaveSpeedPredictionResponse.self, from: data)
        try validateProviderResponse(decoded)
        return decoded
    }

    private static func pollForImages(predictionID: String) async throws -> [Data] {
        guard let url = URL(string: "\(baseURL)\(predictionResultPath)/\(predictionID)/result") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(ImageConfigDefaults().wavespeedApiKey)", forHTTPHeaderField: "Authorization")

        for _ in 0..<maxPollAttempts {
            let (data, response) = try await URLSession.shared.data(for: request)
            try validateHTTPResponse(data: data, response: response, fallbackContext: "Image result")

            let decoded = try JSONDecoder().decode(WaveSpeedPredictionResponse.self, from: data)
            try validateProviderResponse(decoded)

            if let outputs = decoded.data.outputs, !outputs.isEmpty {
                return try await downloadImages(from: outputs)
            }

            if decoded.data.isTerminalFailure {
                throw RuntimeError(decoded.data.error ?? decoded.message ?? "Image generation failed")
            }

            if decoded.data.isCompleted {
                throw RuntimeError(decoded.message ?? "Image generation completed without outputs")
            }

            try await Task.sleep(nanoseconds: pollDelayNanoseconds)
        }

        throw RuntimeError("Timed out waiting for image generation")
    }

    private static func downloadImages(from urls: [String]) async throws -> [Data] {
        var images: [Data] = []

        for output in urls {
            guard let imageURL = URL(string: output) else {
                throw RuntimeError("Invalid image URL: \(output)")
            }

            let (imageData, response) = try await URLSession.shared.data(from: imageURL)

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                throw RuntimeError("Failed to download generated image")
            }

            images.append(imageData)
        }

        guard !images.isEmpty else {
            throw RuntimeError("No valid images downloaded")
        }

        return images
    }

    private static func validateHTTPResponse(data: Data, response: URLResponse, fallbackContext: String) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RuntimeError("Invalid response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? fallbackContext
            throw RuntimeError(errorText)
        }
    }

    private static func validateProviderResponse(_ response: WaveSpeedPredictionResponse) throws {
        if let code = response.code, code != 200 {
            throw RuntimeError(response.data.error ?? response.message ?? "WaveSpeed request failed")
        }
    }
}

private struct WaveSpeedPredictionResponse: Decodable {
    let code: Int?
    let message: String?
    let data: WaveSpeedPredictionData
}

private struct WaveSpeedPredictionData: Decodable {
    let id: String?
    let status: String?
    let outputs: [String]?
    let error: String?

    var isTerminalFailure: Bool {
        guard let status else { return false }
        return ["failed", "canceled", "cancelled"].contains(status.lowercased())
    }

    var isCompleted: Bool {
        status?.lowercased() == "completed"
    }
}
