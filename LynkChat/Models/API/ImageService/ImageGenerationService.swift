//
//  ImageGenerationService.swift
//  LynkChat
//
//  Created by Codex on 03/02/2026.
//

import Foundation

enum ImageGenerationService {
    static func generateImages(config: ImageConfig) async throws -> [Data] {
        try await WaveSpeedImageService.performImageRequest(
            path: config.model.apiPath,
            body: config.model.requestBody(prompt: config.prompt)
        )
    }
}
