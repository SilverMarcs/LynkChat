//
//  ImageEditingService.swift
//  LynkChat
//
//  Created by GitHub Copilot on 11/10/2025.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum ImageEditingService {
    /// Edit images strictly using provided input images and prompt.
    static func editImages(using model: ImageEditingModel, prompt: String, inputImages: [Data]) async throws -> [Data] {
        guard !inputImages.isEmpty else {
            throw RuntimeError("No input images provided for editing")
        }

        let imageURLs = convertToBase64URLs(inputImages)

        // Build request body based on model
        let requestBody: [String: Any]
        let apiPath: String

        switch model {
        case .seedreamV50Lite, .seedreamV45:
            apiPath = model.apiPath
            let size = try calculateOptimalSize(from: inputImages[0], maxDimension: 4096)
            requestBody = [
                "prompt": prompt,
                "images": imageURLs,
                "size": size,
                "enable_sync_mode": false,
                "enable_base64_output": false
            ]

        case .klingImageO3:
            apiPath = model.apiPath
            requestBody = [
                "prompt": prompt,
                "images": imageURLs,
                "aspect_ratio": "9:16",
                "resolution": "1k",
                "output_format": "png"
            ]

        case .grokImagine:
            apiPath = model.apiPath
            requestBody = [
                "prompt": prompt,
                "image": imageURLs[0],
                "aspect_ratio": "9:16",
                "output_format": "jpeg",
                "enable_base64_output": false
            ]

        case .gptImage15:
            apiPath = model.apiPath
            requestBody = [
                "prompt": prompt,
                "images": imageURLs,
                "size": "1024*1536",
                "quality": "medium",
                "output_format": "jpeg",
                "enable_sync_mode": false,
                "enable_base64_output": false
            ]

        case .nanoBanana2:
            apiPath = model.apiPath
            requestBody = [
                "prompt": prompt,
                "images": imageURLs,
                "aspect_ratio": "9:16",
                "resolution": "1k",
                "output_format": "png",
                "enable_sync_mode": false,
                "enable_base64_output": false
            ]
        }

        return try await WaveSpeedImageService.performImageRequest(path: apiPath, body: requestBody)
    }
    
    // MARK: - Helper Functions
    
    private static func convertToBase64URLs(_ images: [Data]) -> [String] {
        images.map { "data:image/png;base64,\($0.base64EncodedString())" }
    }
    
    /// Calculate optimal size string based on image data, maintaining aspect ratio
    private static func calculateOptimalSize(from imageData: Data, maxDimension: Int) throws -> String {
        #if canImport(UIKit)
        guard let image = UIImage(data: imageData) else {
            throw RuntimeError("Failed to decode image data")
        }
        let width = image.size.width * image.scale
        let height = image.size.height * image.scale
        #elseif canImport(AppKit)
        guard let image = NSImage(data: imageData),
              let cgImage = unsafe image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw RuntimeError("Failed to decode image data")
        }
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        #endif
        
        // Calculate aspect ratio
        let aspectRatio = width / height
        
        // Scale to fit within maxDimension while maintaining aspect ratio
        let scaledWidth: Int
        let scaledHeight: Int
        
        if width > height {
            // Landscape or square
            scaledWidth = maxDimension
            scaledHeight = Int(CGFloat(maxDimension) / aspectRatio)
        } else {
            // Portrait
            scaledHeight = maxDimension
            scaledWidth = Int(CGFloat(maxDimension) * aspectRatio)
        }
        
        return "\(scaledWidth)*\(scaledHeight)"
    }
    
}
