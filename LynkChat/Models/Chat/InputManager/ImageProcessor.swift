//
//  ImageProcessor.swift
//  LynkChat
//
//  Created by Zabir Raihan on 03/08/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageProcessor {
    static let maxImageSizeBytes: Int = 2 * 1024 * 1024 // 2MB
    
    static func processImageData(_ data: Data, fileType: UTType, fileName: String) throws -> (Data, UTType, String) {
        // If already under 2MB, return as-is
        guard data.count > maxImageSizeBytes else {
            return (data, fileType, fileName)
        }
        
        // Try to compress the image
        guard let compressedData = compressImage(data: data, targetSizeBytes: maxImageSizeBytes) else {
            throw InputError.imageCompressionFailed
        }
        
        // Return compressed data as JPEG (most efficient for compression)
        let newFileName = fileName.replacingOccurrences(of: ".\(fileType.preferredFilenameExtension ?? "")", with: ".jpg")
        return (compressedData, .jpeg, newFileName)
    }
    
    private static func compressImage(data: Data, targetSizeBytes: Int) -> Data? {
        #if os(macOS)
        return compressImageMacOS(data: data, targetSizeBytes: targetSizeBytes)
        #else
        return compressImageiOS(data: data, targetSizeBytes: targetSizeBytes)
        #endif
    }
    
    #if os(macOS)
    private static func compressImageMacOS(data: Data, targetSizeBytes: Int) -> Data? {
        guard let image = NSImage(data: data) else { return nil }
        
        // Start with high quality and reduce if needed
        var compressionQuality: CGFloat = 0.9
        let qualityStep: CGFloat = 0.1
        
        while compressionQuality > 0.1 {
            // Convert NSImage to CGImage
            guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                return nil
            }
            
            // Create bitmap representation
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            
            // Compress as JPEG
            guard let compressedData = bitmapRep.representation(
                using: .jpeg,
                properties: [.compressionFactor: compressionQuality]
            ) else {
                return nil
            }
            
            // Check if we've reached target size
            if compressedData.count <= targetSizeBytes {
                return compressedData
            }
            
            compressionQuality -= qualityStep
        }
        
        // If still too large, try resizing the image
        return resizeAndCompressImageMacOS(image: image, targetSizeBytes: targetSizeBytes)
    }
    
    private static func resizeAndCompressImageMacOS(image: NSImage, targetSizeBytes: Int) -> Data? {
        let originalSize = image.size
        var scaleFactor: CGFloat = 0.8
        
        while scaleFactor > 0.1 {
            let newSize = NSSize(
                width: originalSize.width * scaleFactor,
                height: originalSize.height * scaleFactor
            )
            
            let resizedImage = NSImage(size: newSize)
            resizedImage.lockFocus()
            image.draw(in: NSRect(origin: .zero, size: newSize))
            resizedImage.unlockFocus()
            
            guard let cgImage = resizedImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                continue
            }
            
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            guard let compressedData = bitmapRep.representation(
                using: .jpeg,
                properties: [.compressionFactor: 0.8]
            ) else {
                continue
            }
            
            if compressedData.count <= targetSizeBytes {
                return compressedData
            }
            
            scaleFactor -= 0.1
        }
        
        return nil
    }
    #else
    private static func compressImageiOS(data: Data, targetSizeBytes: Int) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        
        // Start with high quality and reduce if needed
        var compressionQuality: CGFloat = 0.9
        let qualityStep: CGFloat = 0.1
        
        while compressionQuality > 0.1 {
            guard let compressedData = image.jpegData(compressionQuality: compressionQuality) else {
                return nil
            }
            
            // Check if we've reached target size
            if compressedData.count <= targetSizeBytes {
                return compressedData
            }
            
            compressionQuality -= qualityStep
        }
        
        // If still too large, try resizing the image
        return resizeAndCompressImageiOS(image: image, targetSizeBytes: targetSizeBytes)
    }
    
    private static func resizeAndCompressImageiOS(image: UIImage, targetSizeBytes: Int) -> Data? {
        let originalSize = image.size
        var scaleFactor: CGFloat = 0.8
        
        while scaleFactor > 0.1 {
            let newSize = CGSize(
                width: originalSize.width * scaleFactor,
                height: originalSize.height * scaleFactor
            )
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let resizedImage = resizedImage,
                  let compressedData = resizedImage.jpegData(compressionQuality: 0.8) else {
                continue
            }
            
            if compressedData.count <= targetSizeBytes {
                return compressedData
            }
            
            scaleFactor -= 0.1
        }
        
        return nil
    }
    #endif
}
